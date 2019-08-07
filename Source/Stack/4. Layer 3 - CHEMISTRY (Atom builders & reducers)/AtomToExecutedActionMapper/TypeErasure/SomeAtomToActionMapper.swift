////
//// MIT License
//// 
//// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
//// 
//// Permission is hereby granted, free of charge, to any person obtaining a copy
//// of this software and associated documentation files (the "Software"), to deal
//// in the Software without restriction, including without limitation the rights
//// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//// copies of the Software, and to permit persons to whom the Software is
//// furnished to do so, subject to the following conditions:
//// 
//// The above copyright notice and this permission notice shall be included in all
//// copies or substantial portions of the Software.
//// 
//// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//// SOFTWARE.
////
//
//import Foundation
//import RxSwift
//
//public struct SomeAtomToExecutedActionMapper<SpecificExecutedAction>: AtomToSpecificExecutedActionMapper where SpecificExecutedAction: UserAction {
//    
//    private let _mapAtomToAction: (Atom) -> Observable<SpecificExecutedAction>
//    
//    public init<Concrete>(_ concrete: Concrete) where Concrete: AtomToSpecificExecutedActionMapper, Concrete.SpecificExecutedAction == SpecificExecutedAction {
//        self._mapAtomToAction = { concrete.mapAtomToAction($0) }
//    }
//    
//    public init(any: AnyAtomToExecutedActionMapper) throws {
//        guard any.matches(actionType: SpecificExecutedAction.self) else {
//            throw Error.actionTypeMismatch
//        }
//        self._mapAtomToAction = {
//            any.mapAtomSomeUserAction($0).filterNil().map {
//                return castOrKill(instance: $0, toType: SpecificExecutedAction.self)
//            }
//        }
//    }
//}
//
//public extension SomeAtomToExecutedActionMapper {
//    
//    enum Error: Int, Swift.Error, Equatable {
//        case actionTypeMismatch
//    }
//    
//    func mapAtomToAction(_ atom: Atom) -> Observable<SpecificExecutedAction> {
//        return _mapAtomToAction(atom)
//    }
//}
