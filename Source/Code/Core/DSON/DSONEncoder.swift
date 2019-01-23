//
//  DSONEncoder.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import SwiftCBOR

/// "D" as in "Dan Hughes" - the creator of Radix DLT
/// So "Dson" as in "Dan's Serialised Object Notation"
/// In fact this is using CBOR - Concise Binary Object Representation
/// http://cbor.io/
public struct DSONEncoder {
    func encode<Value>(_ value: Value) -> Data where Value: DSONEncodable {
        return Data(bytes: CBOR.encode(value))
    }
}

public struct DSONDecoder {
    public enum Error: Swift.Error {
        case failedToDecodeRootCBOR
    }
    func decode<D>(data: Data, to type: D.Type) throws -> D where D: DSONDecodable {
        guard let cbor = try CBOR.decode(data.bytes) else {
            throw Error.failedToDecodeRootCBOR
        }
        print(cbor)
        implementMe
    }
}

public protocol DSONEncodable: Encodable, CBOREncodable {}
public protocol DSONDecodable: Decodable {}

public extension DSONEncodable {
    func toDson() -> Data {
        return DSONEncoder().encode(self)
    }
}

public extension CBOREncodable where Self: Encodable {
    // swiftlint:disable:next function_body_length
    func encode() -> [UInt8] {
        do {
            let data = try JSONEncoder().encode(self)
            guard
                let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                else {
                    incorrectImplementation("Failed to create dictionary")
            }
            let cborEncodableDictionary = [String: CBOREncodable](uniqueKeysWithValues: dictionary.compactMap {
                let value = $0.value
                guard let encodableValue = value as? CBOREncodable else {
                    print("⚠️ Value: \(value), of type: \(type(of: value)), not CBOREncodable")
                    return nil
                }
                return ($0.key, encodableValue)
            })
            
            let mappedValues = cborEncodableDictionary.mapValues { CBOR.byteString($0.encode()) }
            let map = [CBOR: CBOR](uniqueKeysWithValues: mappedValues.map { (CBOR(stringLiteral: $0.key), $0.value) })
         
            return CBOR.map(map).encode()
        } catch {
            incorrectImplementation("Should not throw, unexpected error: \(error)")
        }
    }
}

//public protocol CodingKeyOwner where Self: Encodable {
//    associatedtype IterableCodingKey: CodingKey & CaseIterable
//}

//public extension CBOREncodable where Self: CodingKeyOwner {
//    func encode() -> [UInt8] {
//        implementMe
//        IterableCodingKey.allCases.for
//        //        do {
//        //            let jsonData = try JSONEncoder().encode(self)
//        //            return jsonData.
//        //        } catch {
//        //            incorrectImplementation("Shoud not throw, error: \(error)")
//        //        }
//    }
//}
