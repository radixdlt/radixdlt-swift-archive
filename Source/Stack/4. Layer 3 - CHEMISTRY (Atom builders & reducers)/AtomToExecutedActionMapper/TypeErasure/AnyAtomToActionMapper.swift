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

public struct AnyAtomToExecutedActionMapper: BaseAtomToSpecificExecutedActionMapper {
    
    private let _actionType: () -> Any.Type
    private let _matchesType: (Any.Type) -> Bool
    private let _map: (Atom, Any.Type, Account) -> Observable<Any>
    
    public init<Concrete>(_ concrete: Concrete) where Concrete: AtomToSpecificExecutedActionMapper {
        self._actionType = { Concrete.SpecificExecutedAction.self }
        self._matchesType = { return $0 == Concrete.SpecificExecutedAction.self }
        self._map = {
            typeErasureExpects(type: $1, toBe: Concrete.SpecificExecutedAction.Type.self)
            return concrete.map(atom: $0, toActionType: Concrete.SpecificExecutedAction.self, account: $2).map { $0 }
        }
    }
}

public extension AnyAtomToExecutedActionMapper {
    func map<Action>(atom: Atom, toActionType _: Action.Type, account: Account) -> Observable<Action> where Action: ExecutedAction {
        
        return self._map(atom, Action.self, account).map {
            return castOrKill(instance: $0, toType: Action.self)
        }
    }
    
    func matches<Action>(actionType: Action.Type) -> Bool {
        return _matchesType(actionType)
    }
    
    var actionType: Any.Type {
        return _actionType()
    }
}
