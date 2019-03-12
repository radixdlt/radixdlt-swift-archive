//
//  DSONPrefixSpecifying.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// [DSON][1] is binary object representation defined by Radix, based on [CBOR][2] (Concise Binary Object Representation).
///
/// The 'D' in "DSON" stands for "Dan Hughes" (Radix DLT's founder)
///
/// [1]: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/56557727/DSON+Encoding+new
/// [2]: https://cbor.io/
///
/// - seeAlso:
/// `DSONEncoder` for encoding.
///
public protocol DSONPrefixSpecifying {
    var dsonPrefix: DSONPrefix { get }
}
