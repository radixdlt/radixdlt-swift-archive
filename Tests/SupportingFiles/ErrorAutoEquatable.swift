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
@testable import RadixSDK

// MARK: - AutoEquatable
public protocol AutoEquatable: Equatable {
    static func compare(lhs: Self, rhs: Self, beSatisfiedWithSameAssociatedTypeIfTheirValuesDiffer: Bool) -> Bool
}

public extension AutoEquatable {
    
    static func compare(lhs: Self, rhs: Self, beSatisfiedWithSameAssociatedTypeIfTheirValuesDiffer: Bool) -> Bool {
        compareSome(lhs: lhs, rhs: rhs, beSatisfiedWithSameAssociatedTypeIfTheirValuesDiffer: beSatisfiedWithSameAssociatedTypeIfTheirValuesDiffer)
    }
}


// MARK: - Equatable
public extension AutoEquatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        Self.compare(lhs: lhs, rhs: rhs, beSatisfiedWithSameAssociatedTypeIfTheirValuesDiffer: true)
    }
}

// MARK: - ErrorAutoEquatable
public typealias ErrorAutoEquatable = Swift.Error & AutoEquatable

public func == <LHS>(lhs: LHS, rhsAnyError: Swift.Error) -> Bool where LHS: ErrorAutoEquatable {
    guard let rhs = rhsAnyError as? LHS else { return false }
    return compareSome(lhs: lhs, rhs: rhs, beSatisfiedWithSameAssociatedTypeIfTheirValuesDiffer: true)
}

public func == <RHS>(lhsAnyError: Swift.Error, rhs: RHS) -> Bool where RHS: ErrorAutoEquatable {
    guard let lhs = lhsAnyError as? RHS else { return false }
    return compareSome(lhs: lhs, rhs: rhs, beSatisfiedWithSameAssociatedTypeIfTheirValuesDiffer: true)
}

// MARK: - Example
func example() {
    
    enum AnError: ErrorAutoEquatable {
        case anInt(Int)
        case aString(String?)
        case anotherInt(Int)
        case anotherString(String?)
        case aBool(Bool?)
        case stringAndInt(aString: String, anInt: Int)
        case complex(aString: String, anInt: Int, aBool: Bool, aTuple: (String, Int, Bool))
    }
    
    enum AnotherError: ErrorAutoEquatable {
        case anInt(Int)
    }
    
    @discardableResult
    func isSame(_ lhs: AnError, _ rhs: AnError) -> Bool {
        return lhs == rhs
    }
    
    // ALL `true`
    isSame(.anInt(1), .anInt(2)) // true
    isSame(.aBool(true), .aBool(false)) // true
    isSame(.aString("Hello"), .aString("World")) // true
    isSame(.aString("Hello"), .aString(nil)) // true
    
    isSame(
        .complex(aString: "A", anInt: 1, aBool: true, aTuple: ("B", 2, false)),
        .complex(aString: "X", anInt: 8, aBool: false, aTuple: ("Y", 9, true))
    )
    
    var comparison = (AnError.anInt(1) as Swift.Error) == AnError.anInt(1) // true
    comparison = AnError.anInt(1) == (AnError.anInt(1) as Swift.Error) // true
    
    // ALL `false`
    isSame(.anInt(1), .anotherInt(1)) // false
    isSame(.aString("Hello"), .anotherString("World")) // false
    isSame(.aString(nil), .anotherString(nil)) // false
    
    comparison = (AnError.anInt(1) as Swift.Error) == AnotherError.anInt(1) // false
    comparison = AnError.anInt(1) == (AnotherError.anInt(1) as Swift.Error) // false
    
    // Advanced
    comparison = AnError.anInt(1) == AnError.self.anInt // true
    comparison = AnError.stringAndInt(aString: "Some string", anInt: 123) != AnError.self.anInt // true, not equal
    comparison = AnError.stringAndInt(aString: "Some string", anInt: 123) == AnError.stringAndInt // true
    
    print(comparison)
}

protocol EmptyInitializable {
    init()
}
protocol ValueIgnored {
    static var irrelevant: Self { get }
}
typealias Ignored = EmptyInitializable & ValueIgnored
extension ValueIgnored where Self: EmptyInitializable {
    static var irrelevant: Self { .init() }
}

func == <E, A>(instance: E, make: (A) -> E) -> Bool where E: ErrorAutoEquatable, A: Ignored {
    instance == make(A.irrelevant)
}
func != <E, A>(instance: E, make: (A) -> E) -> Bool where E: ErrorAutoEquatable, A: Ignored {
    !(instance == make)
}
func == <E, A, B>(instance: E, make: (A, B) -> E) -> Bool where E: ErrorAutoEquatable, A: Ignored, B: Ignored {
    instance == make(A.irrelevant, B.irrelevant)
}

extension String: Ignored {}
extension Bool: Ignored {}

extension UInt: Ignored {}
extension UInt64: Ignored {}
extension UInt32: Ignored {}
extension UInt16: Ignored {}
extension UInt8: Ignored {}

extension Int: Ignored {}
extension Int64: Ignored {}
extension Int32: Ignored {}
extension Int16: Ignored {}
extension Int8: Ignored {}

