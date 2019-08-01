/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import Foundation
import RxSwift

public struct SomeAtomToExecutedActionMapper<SpecificExecutedAction>: AtomToSpecificExecutedActionMapper where SpecificExecutedAction: ExecutedAction {
    
    private let _map: (Atom, Account) -> Observable<SpecificExecutedAction>
    
    public init<Concrete>(_ concrete: Concrete) where Concrete: AtomToSpecificExecutedActionMapper, Concrete.SpecificExecutedAction == SpecificExecutedAction {
        self._map = { concrete.map(atom: $0, account: $1) }
    }
    
    public init(any: AnyAtomToExecutedActionMapper) throws {
        guard any.matches(actionType: SpecificExecutedAction.self) else {
            throw Error.actionTypeMismatch
        }
        self._map = { any.map(atom: $0, toActionType: SpecificExecutedAction.self, account: $1) }
    }
}

public extension SomeAtomToExecutedActionMapper {
    
    enum Error: Int, Swift.Error, Equatable {
        case actionTypeMismatch
    }
    
    func map(atom: Atom, account: Account) -> Observable<SpecificExecutedAction> {
        return _map(atom, account)
    }
}
