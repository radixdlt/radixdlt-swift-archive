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

public struct AtomEvent: RadixModelTypeStaticSpecifying, Decodable, CustomStringConvertible {
    public let atom: Atom
    public let type: AtomEventType
}

// MARK: - AtomEventType
public extension AtomEvent {
    
    var description: String {
        return """
        .\(type)(atomWithAID: \(atom.shortAid))
        """
    }
    
    // swiftlint:disable colon
    
    /// The events that we can get from an Atom subscription
    enum AtomEventType:
        String,
        StringInitializable,
        PrefixedJsonDecodable,
        Decodable {
        // swiftlint:enable colon
        
        case store, delete
    }
}

// MARK: - AtomEventType + StringInitializable
public extension AtomEvent.AtomEventType {
    init(string: String) throws {
        guard let event = AtomEvent.AtomEventType(rawValue: string) else {
            throw Error.unsupportedAtomEventType(string)
        }
        self = event
    }
    
    enum Error: Swift.Error {
        case unsupportedAtomEventType(String)
    }
}

// MARK: Decodable
public extension AtomEvent {
    
    enum CodingKeys: String, CodingKey {
        case serializer, version
        
        case type
        case atom
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        atom = try container.decode(Atom.self, forKey: .atom)
        type = try container.decode(AtomEventType.self, forKey: .type)
    }
}

public extension AtomEvent {
    var store: AtomEvent? {
        guard type == .store else {
            return nil
        }
        return self
    }
    
    var delete: AtomEvent? {
        guard type == .delete else {
            return nil
        }
        return self
    }
}

// MARK: RadixModelTypeStaticSpecifying
public extension AtomEvent {
    static let serializer = RadixModelType.atomEvent
}
