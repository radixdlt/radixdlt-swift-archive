//
//  JSONPrefix.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// https://radixdlt.atlassian.net/wiki/spaces/AM/pages/56557727/DSON+Encoding+new
public enum JSONPrefix: String, CaseIterable {
    case string = "str"
    case addressBase58 = "adr"
    case uri = "rri"
    case bytesBase64 = "byt"
    case uint256DecimalString = "u20"
    case hashHex = "hsh"
    case euidHex = "uid"
}

public extension JSONPrefix {
    var identifier: String {
        let separator = ":"
        return [
            separator,
            rawValue,
            separator
        ].joined()
    }
}
