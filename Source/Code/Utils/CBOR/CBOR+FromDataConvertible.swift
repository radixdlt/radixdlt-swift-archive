//
//  CBOR+FromDataConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-08.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension CBOR {
    static func bytes(_ data: DataConvertible, dsonPrefix: DSONPrefix) -> CBOR {
        return CBOR.byteString(
            dsonPrefix.additionalInformation + data.bytes
        )
    }
}
