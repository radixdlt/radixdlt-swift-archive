//
//  MetaDataCommonValue.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-30.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum MetaDataCommonValue: String, Equatable {
    case encryptor
    case message
    case applicationJson = "application/json"
}

public extension MetaDataKey {
    static func application(_ commonValue: MetaDataCommonValue) -> MetaData.Element {
        return (key: MetaDataKey.application, value: commonValue.rawValue)
    }
    
    static func contentType(_ commonValue: MetaDataCommonValue) -> MetaData.Element {
        return (key: MetaDataKey.contentType, value: commonValue.rawValue)
    }
}
