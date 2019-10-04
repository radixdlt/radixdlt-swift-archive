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

import SwiftUI

enum All {
    static let gestures = all(of: Gestures.self)
    
    private static func all<CI>(of _: CI.Type) -> CI.AllCases where CI: CaseIterable {
        return CI.allCases
    }
}

enum Gestures: Hashable, CaseIterable {
    case tap, longPress, drag, magnification, rotation
}

protocol ValueGesture: Gesture where Value: Equatable {
    func onChanged(_ action: @escaping (Value) -> Void) -> _ChangedGesture<Self>
}
extension LongPressGesture: ValueGesture {}
extension DragGesture: ValueGesture {}
extension MagnificationGesture: ValueGesture {}
extension RotationGesture: ValueGesture {}

extension Gestures {
    @discardableResult
    func apply<V>(to view: V, perform voidAction: @escaping () -> Void) -> AnyView where V: View {
        
        func highPrio<G>(
            gesture: G
        ) -> AnyView where G: ValueGesture {
            view.highPriorityGesture(
                gesture.onChanged { value in
                    _ = value
                    voidAction()
                }
            ).eraseToAny()
        }
        
        switch self {
        case .tap:
            // not `highPriorityGesture` since tapping is a common gesture, e.g. wanna allow users
            // to easily tap on a TextField in another cell in the case of a list of TextFields / Form
            return view.gesture(TapGesture().onEnded(voidAction)).eraseToAny()
        case .longPress: return highPrio(gesture: LongPressGesture())
        case .drag: return highPrio(gesture: DragGesture())
        case .magnification: return highPrio(gesture: MagnificationGesture())
        case .rotation: return highPrio(gesture: RotationGesture())
        }
        
    }
}

struct DismissingKeyboard: ViewModifier {
    
    var gestures: [Gestures] = Gestures.allCases
    
    dynamic func body(content: Content) -> some View {
        let action = {
            let forcing = true
            let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first
            keyWindow?.endEditing(forcing)
        }
        
        return gestures.reduce(content.eraseToAny()) { $1.apply(to: $0, perform: action) }
    }
}

extension View {
    dynamic func dismissKeyboard(on gestures: [Gestures] = Gestures.allCases) -> some View {
        return ModifiedContent(content: self, modifier: DismissingKeyboard(gestures: gestures))
    }
}
