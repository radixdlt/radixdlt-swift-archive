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

// swiftlint:disable colon opening_brace

/// A collection of Radix addresses, all belonging to the same universe (having the same magic)
public struct Addresses:
    ArrayDecodable,
    Equatable
{

    // swiftlint:enable colon opening_brace

    public let addresses: Set<Address>
    
    public init(addresses: Set<Address>) throws {
        try Addresses.allInSameUniverse(addresses.asArray)
        self.addresses = addresses
    }
}

// MARK: - Throwing
public extension Addresses {

    static func allInSameUniverse(_ addressConvertibles: [AddressConvertible]) throws -> Throws<Void, ActionsToAtomError> {
        let addresses = [Address](addressConvertibles.map { $0.address })
        let head: Address 
        let tail: [Address]
        
        switch addresses.countedElementsZeroOneTwoAndMany {
        case .two(let first, let secondAndLast): head = first; tail = [secondAndLast]
        case .many(let aHead, let aTail): head = aHead; tail = aTail
        default: return
        }

        for address in tail {
            guard address.inTheSameUniverse(as: head) else {
                throw ActionsToAtomError.differentUniverses(addresses: Set(addresses))
            }
        }

        // All is well
    }
}

// MARK: - ArrayDecodable
public extension Addresses {
    typealias Element = Address
    
    var elements: [Element] {
        return addresses.asArray
    }
    
    init(elements: [Element]) {
        do {
            try self.init(addresses: elements.asSet)
        } catch {
            badLiteralValue(elements, error: error)
        }
    }
}
