//
//  AnyEncodableKeyValuesProcessing.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol AnyEncodableKeyValuesProcessing {
    func processProperties(_ properties: [AnyEncodableKeyValue]) throws -> [AnyEncodableKeyValue]
}
