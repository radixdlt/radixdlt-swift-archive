//
//  MetaData.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct MetaData: DictionaryCodable, CBORDictionaryConvertible, Equatable {
    public typealias Key = MetaDataKey
    public typealias Value = String
    public let dictionary: [Key: Value]
    public init(dictionary: Map) {
        self.dictionary = dictionary
    }
}

// MARK: Values for Default Keys
public extension MetaData {
    var timestamp: Date? {
        guard
            let timestampString = self[.timestamp],
            let timeIntervalSince1970 = TimeInterval(timestampString)
        else {
            return nil
        }
        return Date(timeIntervalSince1970: timeIntervalSince1970)
    }
    
    static var timeNow: MetaData {
        return [.timestamp: Int(Date().timeIntervalSinceNow).description]
    }
}
