//
//  Data+StringConversion.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// 
public extension Data {
    func toHexString(case: String.Case? = nil, mode: StringConversionMode? = nil) -> HexString {
        let hexString = HexString(data: asData)
        var hex = hexString.stringValue.changeCaseIfNeeded(to: `case`)
        switch mode {
        case .none: break
        case .minimumLength(let minimumLength, let concatMode)?:
            hex.prependOrAppend(character: "0", toLength: minimumLength, mode: concatMode)
        case .trim?: hex.trim(character: "0")
        }
        
        return HexString(validated: hex)
    }
    
    func toBase64String(minLength: Int? = nil) -> Base64String {
        let data = toData(minByteCount: minLength, concatMode: .prepend)
        return Base64String(data: data)
    }
    
    func toBase58String(minLength: Int? = nil) -> Base58String {
        let data = toData(minByteCount: minLength, concatMode: .prepend)
        return Base58String(data: data)
    }
}
