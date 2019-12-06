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

// MARK: - Compare + Mirror
internal func compareSome<T>(lhs: T, rhs: T, beSatisfiedWithSameAssociatedTypeIfTheirValuesDiffer: Bool) -> Bool {
    compareAny(lhs: lhs, rhs: rhs, beSatisfiedWithSameAssociatedTypeIfTheirValuesDiffer: beSatisfiedWithSameAssociatedTypeIfTheirValuesDiffer)
}

internal func compareAny(lhs: Any, rhs: Any, beSatisfiedWithSameAssociatedTypeIfTheirValuesDiffer: Bool = true) -> Bool {
    let lMirror = Mirror(reflecting: lhs)
    let rMirror = Mirror(reflecting: rhs)
    
    guard
        lMirror.displayStyle == rMirror.displayStyle,
        lMirror.children.count == rMirror.children.count
        else
    { return false }
    
    for indexInt in 0..<lMirror.children.count {
        let index = AnyCollection<(label: String?, value: Any)>.Index(indexInt)
        let lChild = lMirror.children[index]
        let rChild = rMirror.children[index]
        
        guard lChild.label == rChild.label else {
            return false
        }
        
        guard "\(lChild.value)" ==  "\(rChild.value)" else {
            let lChildType = type(of: lChild.value)
            let rChildType = type(of: rChild.value)
            if beSatisfiedWithSameAssociatedTypeIfTheirValuesDiffer && "\(lChildType)" == "\(rChildType)" {
                continue
            } else {
                return false
            }
        }
    }
    
    return true
}
