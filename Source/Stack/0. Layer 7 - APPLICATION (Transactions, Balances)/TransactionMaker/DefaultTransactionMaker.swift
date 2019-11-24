//
// MIT License
//
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation
import Combine

public final class DefaultTransactionMaker: TransactionMaker, AddressOfAccountDeriving, Magical {
    
    /// A mapper from a container of `UserAction`s the user wants to perform, to an `Atom` ready to be pushed to the Radix network (some node).
    private let transactionToAtomMapper: TransactionToAtomMapper
    
    /// Not all accounts of `identity` contain a signing (`private`) key, but all user actions (such as transferring tokens, sending messages etc) requires a cryptographic signature by the signing key, this strategy specifies what to do in those scenarios, and can be changed later in time.
    public var strategyNoSigningKeyIsPresent: StrategyNoSigningKeyIsPresent = .throwErrorDirectly
    
    /// A mapper from `Atom` to `AtomWithFee`
    private let feeMapper: FeeMapper
    
    private let universeConfig: UniverseConfig
    
    private let radixNetworkController: RadixNetworkController
    
    private let activeAccount: AnyPublisher<Account, Never>
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        activeAccount: AnyPublisher<Account, Never>,
        radixNetworkController: RadixNetworkController,
        universeConfig: UniverseConfig,
        transactionToAtomMapper: TransactionToAtomMapper,
        feeMapper: FeeMapper = DefaultProofOfWorkWorker()
    ) {
        self.activeAccount = activeAccount
        self.radixNetworkController = radixNetworkController
        self.universeConfig = universeConfig
        self.transactionToAtomMapper = transactionToAtomMapper
        self.feeMapper = feeMapper
    }
}

public extension DefaultTransactionMaker {
    convenience init(
        activeAccount: AnyPublisher<Account, Never>,
        universe: RadixUniverse
        ) {
        
        let transactionToAtomMapper = DefaultTransactionToAtomMapper(atomStore: universe.atomStore)
        
        self.init(
            activeAccount: activeAccount,
            radixNetworkController: universe.networkController,
            universeConfig: universe.config,
            transactionToAtomMapper: transactionToAtomMapper
        )
    }
}

// MARK: Magical
public extension DefaultTransactionMaker {
    var magic: Magic { return universeConfig.magic }
}

public extension DefaultTransactionMaker {
    func atomFrom(transaction: Transaction, addressOfActiveAccount: Address) throws -> Atom {
        return try transactionToAtomMapper.atomFrom(transaction: transaction, addressOfActiveAccount: addressOfActiveAccount)
    }
}

public extension DefaultTransactionMaker {
    func send(transaction: Transaction, toOriginNode originNode: Node?) throws -> ResultOfUserAction {
        
        do {
            
            let unsignedAtom = try buildAtomFrom(transaction: transaction)
            
            let signedAtom = sign(atom: unsignedAtom)
            
            return createAtomSubmission(
                atom: signedAtom,
                completeOnAtomStoredOnly: false,
                originNode: originNode
            )
        } catch let failedToStageAction as StageActionError {
            throw failedToStageAction
        } catch {
            unexpectedlyMissedToCatch(error: error)
        }
    }
}

private extension DefaultTransactionMaker {
    
    func addFee(to atom: Atom) -> Single<AtomWithFee, Never> {
        return activeAccount.flatMap { [weak self] account -> AnyPublisher<AtomWithFee, Never> in
            guard let self = self else {
                return Empty<AtomWithFee, Never>(completeImmediately: true).eraseToAnyPublisher()
            }
            return self.feeMapper.feeBasedOn(
                atom: atom,
                universeConfig: self.universeConfig,
                key: account.publicKey
            )
            .crashOnFailure()
        }
        .eraseToAnyPublisher()
    }
    
    func sign(atom atomPublisher: AnyPublisher<UnsignedAtom, Never>) -> Single<SignedAtom, Never> {
        return atomPublisher
            .withLatest(from: activeAccount) { (atom: $0, account: $1) }
            .tryFilter {
                if $0.account.privateKey == nil, case .throwErrorDirectly = self.strategyNoSigningKeyIsPresent {
                    throw SigningError.noSigningKeyPresentButWasExpectedToBe
                }
                return true
            }
            .crashOnFailure()
            .flatMap { atomAndAccount -> Single<SignedAtom, Never> in
                let (atom, account) = atomAndAccount
               
                return account.sign(atom: atom)
                    .crashOnFailure()
            }
        .eraseToAnyPublisher()
    }
    
    func createAtomSubmission(
        atom atomSingle: Single<SignedAtom, Never>,
        completeOnAtomStoredOnly: Bool,
        originNode: Node?
    ) -> ResultOfUserAction {
        
        let cachedAtom = atomSingle.share()
        
        let submitAtomStatusUpdatesPublisher = cachedAtom
            .flatMap { [weak self] (atom: SignedAtom) -> AnyPublisher<SubmitAtomAction, Never> in
                
                guard let self = self else {
                    return Empty<SubmitAtomAction, Never>(completeImmediately: true).eraseToAnyPublisher()
                }
                
                let initialAction: SubmitAtomAction

                if let originNode = originNode {
                    initialAction = SubmitAtomActionSend(atom: atom, node: originNode, isCompletingOnStoreOnly: completeOnAtomStoredOnly)
                } else {
                    initialAction = SubmitAtomActionRequest(atom: atom, isCompletingOnStoreOnly: completeOnAtomStoredOnly)
                }

                let status: AnyPublisher<SubmitAtomAction, Never> = self.radixNetworkController
                    .getActions()
                    .compactMap(typeAs: SubmitAtomAction.self)
                    .filter { $0.uuid == initialAction.uuid }
                    .prefix(while: { !$0.isCompleted })
                    .eraseToAnyPublisher()

                self.radixNetworkController.dispatch(nodeAction: initialAction)
                return status
            }
        .share()
        .eraseToAnyPublisher()

        let result = ResultOfUserAction(
            submitAtomStatusUpdatesPublisher: submitAtomStatusUpdatesPublisher,
            cachedAtom: cachedAtom.eraseToAnyPublisher()
        )

        return result
    }
    
    var addressOfActiveAccount: AnyPublisher<Address, Never> {
        return activeAccount.compactMap { [weak self] account -> Address? in
            guard let self = self else { return nil }
            return self.addressOf(account: account)
        }
        .eraseToAnyPublisher()
    }
    
    func buildAtomFrom(transaction: Transaction) throws -> Single<UnsignedAtom, Never> {
        addressOfActiveAccount.tryMap { [weak self] address -> Atom in
            guard let self = self else {
                // TODO Combine: Replace fatalError with error
                fatalError("Self is nil")
            }
            return try self.transactionToAtomMapper.atomFrom(transaction: transaction, addressOfActiveAccount: address)
        }
        .crashOnFailure()
        .flatMap { [weak self] atom -> AnyPublisher<AtomWithFee, Never> in
            guard let self = self else {
                // TODO Combine: Replace empty with error
                return Empty<AtomWithFee, Never>.init(completeImmediately: true).eraseToAnyPublisher()
            }
            return self.addFee(to: atom).eraseToAnyPublisher()
        }
        .tryMap { atomWithFee in
            try UnsignedAtom(atomWithPow: atomWithFee)
        }
        .crashOnFailure()
    }
}
