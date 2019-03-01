//
//  RadixEncoder.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public typealias JSONEncoder = RadixEncoder

public final class RadixEncoder: Foundation.JSONEncoder {
    
    convenience init(outputFormat: Foundation.JSONEncoder.OutputFormatting = .sortedKeys) {
        self.init()
        self.outputFormatting = outputFormat
    }
}
