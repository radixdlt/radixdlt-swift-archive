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

public typealias PublicKeyHashEUID = HashEUID
public protocol DestinationsOwner {
    func destinations() -> [PublicKeyHashEUID]
}

/// An abstract type bundling together particles
public protocol ParticleConvertible: RadixHashable, DSONEncodable, CustomDebugStringConvertible, Codable, DestinationsOwner {
    var particleType: ParticleType { get }

    var debugPayloadDescription: String { get }
    
    func shardables() throws -> Addresses?
}

public extension ParticleConvertible {
    var debugPayloadDescription: String { "❓" }

    var debugDescription: String {
        return "\(particleType.debugEmoji)\(particleType.debugName)(\(debugPayloadDescription))"
    }
}

public extension DestinationsOwner where Self: Accountable {
    func destinations() -> [PublicKeyHashEUID] {
        // swiftlint:disable:next force_try
        return try! addresses().elements.map { $0.publicKey.hashEUID }.sorted()
    }
}

public extension ParticleConvertible {
    func shardables() throws -> Addresses? {

        guard let accountable = self as? Accountable else {
            return nil
        }
        
        return try accountable.addresses()
    }
}

public extension ParticleConvertible where Self: RadixModelTypeStaticSpecifying {
    var particleType: ParticleType {
        do {
            return try ParticleType(serializer: serializer)
        } catch {
            incorrectImplementation("Error: \(error)")
        }
    }
}

