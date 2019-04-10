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
            var jsonString = String(data: data)
            //
            // BEWARE! Here be dragons!
            //
            // This is the ugliest hack ever...
            // We would like to append the json key-value pair `"version": 100`, in the JSON
            // but that requires each CodingKey enum to declare `version`, which makes HAVE To
            // implement a custom `init(from decoder: Decoder) throws` init, since we do not have
            // stored property version (and dont want to) in our models.
            // This hack appends this JSON key-value pair before sending to the API if
            // the JSON key-value pair `"serializer": <ID>` is present.
            let needle = "\"\(RadixModelType.jsonKey)"
            
            let replacment = "\"\(jsonKeyVersion)\": \(serializerVersion), \(needle)"
            
            jsonString = jsonString.replacingOccurrences(of: needle, with: replacment)
            return jsonString
        } catch {
            incorrectImplementation("Should be able to encode `self` to JSON string")
        }
    }
}
