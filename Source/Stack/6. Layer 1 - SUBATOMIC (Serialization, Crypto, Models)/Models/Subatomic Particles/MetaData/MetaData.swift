//
//  MetaData.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct MetaData: MetaDataConvertible, ArrayInitializable {

    public let dictionary: [Key: Value]
    
    public init(dictionary: Map) {
        self.dictionary = dictionary
    }
}

// MARK: - MetaDataConvertible
public extension MetaData {
    typealias Element = (key: Key, value: Value)
    typealias Key = MetaDataKey
    typealias Value = String
}
