//
//  DsonTag.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

extension String: StringInitializable {
    public static var dsonTag: DsonTag {
        return .string
    }
    
    public init(string: String) throws {
        self = string
    }
}

/// https://radixdlt.atlassian.net/wiki/spaces/AM/pages/56557727/DSON+Encoding+new
public enum DsonTag: String, CaseIterable {
    case string = "str"
    case addressBase58 = "adr"
    case uri = "rri"
    case bytesBase64 = "byt"
    case uint256DecimalString = "u20"
    case hashHex = "hsh"
    case euidHex = "uid"
}

public extension DsonTag {
    var dataType: StringInitializable.Type {
        switch self {
        case .addressBase58: return Base58String.self
        case .bytesBase64: return Base64String.self
        case .uri, .string, .uint256DecimalString: return String.self
        case .euidHex, .hashHex: return HexString.self
        }
    }
}
