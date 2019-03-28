//
//  RadixJSONDecoder.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public typealias JSON = [String: Any]

public final class RadixJSONDecoder: Foundation.JSONDecoder {
    
    // swiftlint:disable:next function_body_length
    public override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable & RadixModelTypeStaticSpecifying {
        let jsonObjectAny = try JSONSerialization.jsonObject(with: data, options: [])
        
        func handle(jsonObject: JSON) throws {
            guard let modelTypeInt = jsonObject[RadixModelType.jsonKey] as? Int else {
                throw AtomModelDecodingError.noSerializer(in: jsonObject)
            }
            let modelType = try RadixModelType(serializerId: modelTypeInt)
            guard modelType == T.serializer else {
                throw AtomModelDecodingError.jsonDecodingErrorTypeMismatch(expectedSerializer: T.serializer, butGot: modelType)
            }
        }
        
        if let json = jsonObjectAny as? JSON {
            try handle(jsonObject: json)
        } else if let jsonArray = jsonObjectAny as? [JSON] {
            try jsonArray.forEach { try handle(jsonObject: $0) }
        } else {
            incorrectImplementation("Forgot some case..., got jsonObjectAny: <\(jsonObjectAny)>")
        }

        return try super.decode(type, from: data)
    }
    
}
