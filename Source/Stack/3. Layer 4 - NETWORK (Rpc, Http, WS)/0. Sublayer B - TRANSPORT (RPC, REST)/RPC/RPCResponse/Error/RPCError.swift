//
//  RPCError.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum RPCError: Swift.Error, Decodable, Equatable {
    case requestError(RPCRequestError)
    
    /// Received response containing `"params"` or `"result"`, thus a valid response, but failed to decode it into a model.
    case failedToDecodeResponse(DecodingError) // Instantiated from RPCResult
    
    case unrecognizedJson(jsonString: String)
    
    /// Received error from API, but failed to decode the error itself => "metaError"
    case metaError(DecodingError)
}

// MARK: - Decodable
public extension RPCError {
    
    enum CodingKeys: String, CodingKey {
        case error
    }
    
    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self = .requestError(try container.decode(RPCRequestError.self, forKey: .error))
        } catch let decodingError as DecodingError {
            self = .metaError(decodingError)
        } catch {
            incorrectImplementation("Forgot some scenario, got non `DecodingError`: \(error)")
        }
    }
}
