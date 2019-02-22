//
//  JSONDecoder+Dson.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension JSONDecoder {
    func decode<S, D>(_ type: S.Type, from data: Data) throws -> [D]
        where
        S: Sequence,
        D: Decodable & DsonDecodable,
        S.Element == D {
        return try decode([Dson<D>].self, from: data).map {
            $0.value
        }
    }
}
