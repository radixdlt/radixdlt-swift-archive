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

public typealias HashEUID = EUID

public protocol RadixHashable {
    var radixHash: RadixHash { get }
    var hashEUID: HashEUID { get }
}

public extension RadixHashable {
    var hashEUID: HashEUID {
        return radixHash.toEUID()
    }
}

public extension RadixHashable where Self: DSONEncodable {
    var radixHash: RadixHash {
        do {
            return RadixHash(unhashedData: try toDSON(output: .hash))
        } catch {
            incorrectImplementation("Should always be able to hash, error: \(error)")
        }
    }
}

// MARK: - Hashable Prepare
public extension RadixHashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(radixHash)
    }
}
