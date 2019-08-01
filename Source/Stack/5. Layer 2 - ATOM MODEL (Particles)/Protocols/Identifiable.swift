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

/// A type that is identifiable using a `ResourceIdentifier`.
///
/// Since and `ResourceIdentifier` has an `Address`, this type also conforms to `Accoutable`,
/// containing a single address.
///
/// Although this protocol looks very similar to `TokenDefinitionReferencing` - which also has
/// a `ResourceIdentifier` property, they are used differently. This type
/// is defining an identifiable type, whereas `TokenDefinitionReferencing`
/// references this type.
///
/// - seeAlso: `TokenDefinitionReferencing`
/// - seeAlso: `ResourceIdentifier`
/// - seeAlso: `TokenDefinitionParticle`
public protocol Identifiable:
    Accountable,
    Hashable
{
    
    // swiftlint:enable colon opening_brace
    
    var identifier: ResourceIdentifier { get }
}

// MARK: - Accountable
public extension Identifiable {
    var addresses: Addresses {
        return Addresses(identifier.address)
    }
}
