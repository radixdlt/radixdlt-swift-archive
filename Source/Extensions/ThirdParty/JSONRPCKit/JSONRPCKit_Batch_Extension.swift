//
//  JSONRPCKit_Batch_Extension.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import JSONRPCKit

extension JSONRPCKit.Batch1 {
    var requestId: Int {
        guard let requestIdEnum = batchElement.id else {
            incorrectImplementation("Should have a request Id")
        }
        switch requestIdEnum {
        case .number(let requestIdInteger): return requestIdInteger
        case .string: incorrectImplementation("Please use Integers")
        }
    }
    
    var jsonString: String {
        let encoder = RadixJSONEncoder()
        do {
            let data = try encoder.encode(self)
            return String(data: data)
        } catch {
            incorrectImplementation("Should be able to encode `self` to JSON string")
        }
    }
}
