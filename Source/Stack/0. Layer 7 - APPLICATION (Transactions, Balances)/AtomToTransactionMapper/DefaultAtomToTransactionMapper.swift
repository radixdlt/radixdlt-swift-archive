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

public final class DefaultAtomToTransactionMapper: AtomToTransactionMapper {
    
    /// A list of type-erased mappers from `Atom` to `UserAction`
    private let atomToExecutedActionMappers: [AnyAtomToExecutedActionMapper]
    
    public init(activeAccount: AnyPublisher<Account, Never>) {
        atomToExecutedActionMappers = .atomToActionMappers(activeAccount: activeAccount)
    }
}

public extension DefaultAtomToTransactionMapper {
    convenience init(identity: AbstractIdentity) {
        self.init(activeAccount: identity.activeAccountObservable)
    }
}

public extension DefaultAtomToTransactionMapper {
    
    func transactionFromAtom(_ atom: Atom) -> AnyPublisher<ExecutedTransaction, Never> {
//        return CombineObservable.combineLatest(
//            atomToExecutedActionMappers.map { $0.mapAtomSomeUserActions(atom) }
//        ) { $0.flatMap { $0 } }
//            .map { optionalActions in return optionalActions.compactMap { $0 } }
//            .map { ExecutedTransaction(atom: atom, actions: $0) }
        combineMigrationInProgress()
    }
    
}

// MARK: - Default mappers
public extension Array where Element == AnyAtomToExecutedActionMapper {
    static func atomToActionMappers(activeAccount: AnyPublisher<Account, Never>) -> [AnyAtomToExecutedActionMapper] {
        return [
            AnyAtomToExecutedActionMapper(any: DefaultAtomToSendMessageActionMapper(activeAccount: activeAccount) ),
            AnyAtomToExecutedActionMapper(any: DefaultAtomToCreateTokenMapper()),
            AnyAtomToExecutedActionMapper(any: DefaultAtomToTokenTransferMapper()),
            AnyAtomToExecutedActionMapper(any: DefaultAtomToBurnTokenMapper()),
            AnyAtomToExecutedActionMapper(any: DefaultAtomToMintTokenMapper()),
            AnyAtomToExecutedActionMapper(any: DefaultAtomToUniqueIdMapper())
        ]
    }
}
