//
//  Mnemonic+Error.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Mnemonic {
    enum Error: Swift.Error {
        case generatingRandomBytes
        case unexpectedWordCount
    }
}

// MARK: - From BitcoinKit
import BitcoinKit
internal extension Mnemonic.Error {
    init(fromBitcoinKitError bitcoinKitMnemonicError: BitcoinKit.MnemonicError) {
        switch bitcoinKitMnemonicError {
        case .randomBytesError: self = .generatingRandomBytes
        }
    }
}
