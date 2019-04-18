//
//  DataConvertible+StringConversion.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// MARK: - Base Conversion
public extension DataConvertible {
    func toHexString(case: String.Case? = nil, mode: StringConversionMode? = nil) -> HexString {
        return asData.toHexString(case: `case`, mode: mode)
    }
    
    func toBase64String(minLength: Int? = nil) -> Base64String {
        return asData.toBase64String(minLength: minLength)
    }
    
    func toBase58String(minLength: Int? = nil) -> Base58String {
        return asData.toBase58String(minLength: minLength)
    }
    
    var hex: String {
        return toHexString().stringValue
    }
    
    var base58: String {
        return toBase58String().stringValue
    }
    
    var base64: String {
        return toBase64String().stringValue
    }
}
