//
//  ResponseOnFireAndForgetRequest.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-09.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// Used in RPC for Completable requests, where we just care if the request did not result in error, but we dont care about anything else.
internal struct ResponseOnFireAndForgetRequest: Decodable {
    
    public init (from decoder: Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let anyDecodable = try singleValueContainer.decode(AnyDecodable.self)
        guard let json = anyDecodable.value as? JSON else {
            incorrectImplementation("should be JSON")
        }
        if let anySuccessValue = json["success"] {
            guard let successValue = anySuccessValue as? Bool, case let wasSuccessful = successValue else {
                incorrectImplementation("should be bool")
            }
            if wasSuccessful {
                // ALL OK!
            } else {
                incorrectImplementation("expected error...")
            }
        } else if let anyErrorValue = json["error"] {
            throw RPCError.unrecognizedJson(jsonString: String(describing: anyErrorValue))
        }
        
    }
}
