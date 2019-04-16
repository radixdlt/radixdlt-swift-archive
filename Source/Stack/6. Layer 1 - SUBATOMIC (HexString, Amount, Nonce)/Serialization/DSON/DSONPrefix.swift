//
//  DSONPrefix.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// Encoding type information, for more information see the column "Additional Encoding" in the [DSON][1] table
///
/// [1]: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/56557727/DSON+Encoding+new
public enum DSONPrefix: Int {
    case bytesBase64 = 0x01
    case euidHex = 0x02
    case hashHex = 0x03
    case addressBase58 = 0x04
    case unsignedBigInteger = 0x05
    case radixResourceIdentifier = 0x06
}

public extension DSONPrefix {
    var additionalInformation: Data {
        return Byte(rawValue).asData
    }
}
