//
//  KeyValueSpecifying.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol KeyValueSpecifying {
    associatedtype CodingKeys: CodingKey
    var keyValues: [EncodableKeyValue<CodingKeys>] { get }
}

// MARK: Encodable
public extension Encodable where Self: KeyValueSpecifying {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try keyValues.forEach {
            try $0.jsonEncoded(by: &container)
        }
    }
}
