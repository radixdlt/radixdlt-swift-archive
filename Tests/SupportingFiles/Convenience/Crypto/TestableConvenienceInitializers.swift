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

extension HierarchicalDeterministicWallet {
    init() {
        let mnemonic = try! Mnemonic.Generator().generate()
        self.init(mnemonic: mnemonic)
    }
    
    init(mnemonic: Mnemonic) {
        self.init(mnemonic: mnemonic, network: .testnet(.winterfell))
    }
}

extension KeyPair {
    init() {
        let wallet = HierarchicalDeterministicWallet()
        self = try! wallet.keyPairFor(index: 0)
    }
}

extension Mnemonic: ExpressibleByArrayLiteral {
    init(strings: [String]) {
        // Assumes English
        try! self.init(strings: strings, language: .english)
    }
    
    public init(arrayLiteral elements: String...) {
        self.init(strings: elements)
    }
}

extension Mnemonic: ExpressibleByStringLiteral {
    public init(stringLiteral words: String) {
        self.init(strings: words.components(separatedBy: " "))
    }
}

// MARK: - ExpressibleByStringLiteral
public extension ExpressibleByStringLiteral where Self: StringInitializable {
    init(stringLiteral unvalidated: String) {
        do {
            try self.init(string: unvalidated)
        } catch {
            badLiteralValue(unvalidated, error: error)
        }
    }
}

extension RadixHash: ExpressibleByStringLiteral {
    public init(stringLiteral unvalidated: String) {
        do {
            let hexString = try HexString(string: unvalidated)
            guard hexString.length == 64 else {
                fatalError("HexString should be 64 chars long")
            }
            self.init(unhashedData: hexString.asData, hashedBy: SkipHashing())
        } catch {
            badLiteralValue(unvalidated, error: error)
        }
    }
}
