//
//  DataQuark.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct DataQuark: QuarkConvertible {
    public let payload: Data
    public let metaData: MetaData?
    
    public init(payload: Data, metaData: MetaData?) {
        self.payload = payload
        self.metaData = metaData
    }
}
