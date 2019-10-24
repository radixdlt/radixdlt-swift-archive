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

// MARK: TransactionSubscriber
public protocol TransactionSubscriber: AtomToTransactionMapper {
    func observeTransactions(at address: Address) -> CombineObservable<ExecutedTransaction>
}

public extension TransactionSubscriber {
    /// Boolean `OR` of `actionTypes`
    func observeTransactions(
        at address: Address,
        containingActionOfAnyType actionTypes: [UserAction.Type]
    ) -> AnyPublisher<ExecutedTransaction, Never> {
        
        observeTransactions(at: address)
            .filter {
                $0.contains(actionMatchingAnyType: actionTypes)
            }
            .eraseToAnyPublisher()
    }
    
    /// Boolean `AND` of `requiredActionTypes`
    func observeTransactions(
        at address: Address,
        containingActionsOfAllTypes requiredActionTypes: [UserAction.Type]
    ) -> AnyPublisher<ExecutedTransaction, Never> {
        
        observeTransactions(at: address)
            .filter {
                $0.contains(actionMatchingAll: requiredActionTypes)
            }
            .eraseToAnyPublisher()
    }
    
    func observeActions<Action>(
        ofType actionType: Action.Type,
        at address: Address
    ) -> AnyPublisher<Action, Never> where Action: UserAction {
        
//        observeTransactions(at: address)
//            .flatMap { CombineObservable.from($0.actions(ofType: actionType)) }
//        .eraseToAnyPublisher()
        combineMigrationInProgress()
    }
    
}

public extension TransactionSubscriber where Self: ActiveAccountOwner {
    
    /// Do not confuse this with `observeMyTokenTransfers`, this returns a stream of `ExecutedTransaction`, which is
    /// a container of UserActions submitted in a single Atom at some earlier point in time, the latter is a stream
    /// of executed Token Transfers, either by you or someone else.
    func observeMyTransactions() -> CombineObservable<ExecutedTransaction> {
        return observeTransactions(at: addressOfActiveAccount)
    }
    
    /// Do not confuse this with `observeMyTokenTransfers`, this returns a stream of `ExecutedTransaction`, which is
    /// a container of UserActions submitted in a single Atom at some earlier point in time, the latter is a stream
    /// of executed Token Transfers, either by you or someone else.
    /// Boolean `OR` of `actionTypes`
    func observeMyTransactions(containingActionOfAnyType actionTypes: [UserAction.Type]) -> CombineObservable<ExecutedTransaction> {
        return observeTransactions(at: addressOfActiveAccount, containingActionOfAnyType: actionTypes)
    }
    
    /// Do not confuse this with `observeMyTokenTransfers`, this returns a stream of `ExecutedTransaction`, which is
    /// a container of UserActions submitted in a single Atom at some earlier point in time, the latter is a stream
    /// of executed Token Transfers, either by you or someone else.
    /// Boolean `AND` of `requiredActionTypes`
    func observeMyTransactions(containingActionsOfAllTypes requiredActionTypes: [UserAction.Type]) -> CombineObservable<ExecutedTransaction> {
        return observeTransactions(at: addressOfActiveAccount, containingActionsOfAllTypes: requiredActionTypes)
    }
    
    func observeMyActions<Action>(ofType actionType: Action.Type) -> CombineObservable<Action> where Action: UserAction {
        return observeActions(ofType: actionType, at: addressOfActiveAccount)
    }
}
