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
import RxSwift
import RxSwiftExt
import RxOptional

public protocol AtomToTransactionMapper {
    func transactionFromAtom(_ atom: Atom) -> Observable<ExecutedTransaction>
}

public extension AtomToTransactionMapper {
    /// Boolean `OR` of `actionTypes`
    func transactionFrom(atom: Atom, actionMatchingAnyType actionTypes: [UserAction.Type]) -> Observable<ExecutedTransaction> {
        return transactionFromAtom(atom).filter {
            $0.contains(actionMatchingAnyType: actionTypes)
        }
    }
    
    /// Boolean `AND` of `requiredActionTypes`
    func transactionFrom(atom: Atom, actionMatchingAllTypes requiredActionTypes: [UserAction.Type]) -> Observable<ExecutedTransaction> {
        return transactionFromAtom(atom).filter {
            $0.contains(actionMatchingAll: requiredActionTypes)
        }
    }
}

public final class DefaultAtomToTransactionMapper: AtomToTransactionMapper {
    
    /// A list of type-erased mappers from `Atom` to `UserAction`
    private let atomToExecutedActionMappers: [AnyAtomToExecutedActionMapper]
    
    public init(activeAccount: Observable<Account>) {
        atomToExecutedActionMappers = .atomToActionMappers(activeAccount: activeAccount)
    }
}

public extension DefaultAtomToTransactionMapper {
    convenience init(identity: AbstractIdentity) {
        self.init(activeAccount: identity.activeAccountObservable)
    }
}

public extension DefaultAtomToTransactionMapper {
    func transactionFromAtom(_ atom: Atom) -> Observable<ExecutedTransaction> {
        return Observable.combineLatest(
            atomToExecutedActionMappers.map { $0.mapAtomSomeUserAction(atom) }
        ) { $0 } // Observable<[UserAction?]>
            .map { $0.compactMap { $0 } } // Observable<[UserAction]>
            .map { try? NonEmptyArray(unvalidated: $0) } // Observable<NonEmptyArray?>
            .filterNil() // Observable<NonEmptyArray>
            .map { ExecutedTransaction(atom: atom, actions: $0) }
    }
}
