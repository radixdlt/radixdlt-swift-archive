//
//  TestableConvenienceInitializers.swift
//  RadixSDKTests
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
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
