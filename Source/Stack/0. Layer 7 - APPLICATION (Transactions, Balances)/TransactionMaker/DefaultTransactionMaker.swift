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

public final class DefaultTransactionMaker: TransactionMaker, TransactionToAtomMapper, AddressOfAccountDeriving, Magical {
    
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

// MARK: TransactionToAtomMapper
public extension DefaultTransactionMaker {
    func atomFrom(transaction: Transaction, addressOfActiveAccount: Address) throws -> Throws<Atom, ActionsToAtomError> {
        return try transactionToAtomMapper.atomFrom(transaction: transaction, addressOfActiveAccount: addressOfActiveAccount)
    }
}

// MARK: - TransactionMaker
public extension DefaultTransactionMaker {
    func send(transaction: Transaction, toOriginNode originNode: Node?) -> ResultOfUserAction {
        
        let unsignedAtom = unsignedAtomFrom(transaction: transaction)
        let signedAtom = sign(atom: unsignedAtom)
        
        return createAtomSubmission(
            transaction: transaction,
            atom: signedAtom,
            completeOnAtomStoredOnly: false,
            originNode: originNode
        )
    }
}

private extension DefaultTransactionMaker {
    
    func addFee(to atom: Atom) -> AnyPublisher<AtomWithFee, TransactionError> {
        activeAccount
            .setFailureType(to: AtomWithFee.Error.self)
            .flatMap { [unowned self] account -> AnyPublisher<AtomWithFee, AtomWithFee.Error> in
                self.feeMapper.feeBasedOn(
                    atom: atom,
                    universeConfig: self.universeConfig,
                    key: account.publicKey
                )
            }
            .mapError { TransactionError.addFeeError($0) }
            .eraseToAnyPublisher()
    }
    
    var signingAccount: AnyPublisher<Account, TransactionError> {
        activeAccount
            .tryFilter { [unowned self] account in
                if account.privateKey == nil, case .throwErrorDirectly = self.strategyNoSigningKeyIsPresent {
                    throw SigningError.noSigningKeyPresentButWasExpectedToBe
                }
                return true
            }
        .mapError { castOrKill(instance: $0, toType: SigningError.self) }
        .mapError { TransactionError.signAtomError($0) }
        .eraseToAnyPublisher()
    }
    
    func sign(atom unsignedAtomPublisher: AnyPublisher<UnsignedAtom, TransactionError>) -> AnyPublisher<SignedAtom, TransactionError> {
        unsignedAtomPublisher
            .withLatest(from: signingAccount) { (atom: $0, account: $1) }
            .flatMap { atomAndAccount -> AnyPublisher<SignedAtom, TransactionError> in
                let (atom, account) = atomAndAccount
               
                return account.sign(atom: atom)
                    .mapError { TransactionError.signAtomError($0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func createAtomSubmission(
        transaction: Transaction,
        atom signedAtomPublisher: AnyPublisher<SignedAtom, TransactionError>,
        completeOnAtomStoredOnly: Bool,
        originNode: Node?
    ) -> ResultOfUserAction {
        
        let cachedAtomPublisher = signedAtomPublisher.share().eraseToAnyPublisher()
        
        let nonFailingAtomPublisher = cachedAtomPublisher.catch { _ in
            Empty<SignedAtom, Never>(completeImmediately: false)
                .eraseToAnyPublisher()
        }
        
        let transactionErrors: AnyPublisher<Never, TransactionError> = cachedAtomPublisher
            .flatMap { _ in
                // Should never finish, only complete with error
                Empty<Never, TransactionError>(completeImmediately: false)
            }
        .eraseToAnyPublisher()
        
        let updates = nonFailingAtomPublisher.flatMap { [unowned self]
            (atom: SignedAtom) -> AnyPublisher<SubmitAtomAction, Never> in
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
        .eraseToAnyPublisher()

        let result = ResultOfUserAction(
            transaction: transaction,
            transactionErrors: transactionErrors,
            updates: updates
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

    func buildAtomFrom(transaction: Transaction) -> AnyPublisher<Atom, TransactionError> {
        addressOfActiveAccount.tryMap { [unowned self] address throws -> Throws<Atom, ActionsToAtomError> in
            try self.atomFrom(transaction: transaction, addressOfActiveAccount: address)
        }
        .mapError { castOrKill(instance: $0, toType: ActionsToAtomError.self) }
        .mapError { TransactionError.actionsToAtomError($0) }
        .eraseToAnyPublisher()
    }
    
    func unsignedAtomFrom(transaction: Transaction) -> AnyPublisher<UnsignedAtom, TransactionError> {
        buildAtomFrom(transaction: transaction)
            .flatMap { [unowned self] atom -> AnyPublisher<AtomWithFee, TransactionError> in
                self.addFee(to: atom)
            }
            .map { atomWithFee in
                UnsignedAtom.withFee(atomWithFee)
            }
            .eraseToAnyPublisher()
    }
}

public typealias SuccessAndFailurePublishers<Output, Failure: Error> = (success: AnyPublisher<Output, Never>, failure: AnyPublisher<Never, Failure>)

private extension UnsignedAtom {
    static func withFee(_ atomWithFee: AtomWithFee) -> Self {
        do {
            return try Self(atomWithPow: atomWithFee)
        } catch {
            incorrectImplementationShouldAlwaysBeAble(to: "Init UnsignedAtom with AtomWithFee")
        }
        
    }
}
