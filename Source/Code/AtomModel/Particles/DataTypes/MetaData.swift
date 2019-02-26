//
//  MetaData.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct MetaData: DictionaryDecodable, Equatable {
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
        guard let timestampString = self[.timestamp] else {
            return nil
        }
        return DateFormatter(dateStyle: .full).date(from: timestampString)
    }
}
