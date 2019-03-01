//
//  RadixDecoder.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public final class RadixDecoder: Foundation.JSONDecoder {
    public override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable & RadixModelTypeStaticSpecifying {
        let jsonObjectAny = try JSONSerialization.jsonObject(with: data, options: [])
        guard let json = jsonObjectAny as? [String: Any] else {
            throw AtomModelDecodingError.noDictionary
        }
        guard let modelTypeInt = json[RadixModelType.jsonKey] as? Int else {
            throw AtomModelDecodingError.noSerializer
        }
        guard let modelType = RadixModelType(rawValue: modelTypeInt) else {
            throw AtomModelDecodingError.unknownSerializer(got: modelTypeInt)
        }
        guard modelType == T.type else {
            throw AtomModelDecodingError.jsonDecodingErrorTypeMismatch(expectedType: T.type, butGot: modelType)
        }
        return try super.decode(type, from: data)
    }
}
