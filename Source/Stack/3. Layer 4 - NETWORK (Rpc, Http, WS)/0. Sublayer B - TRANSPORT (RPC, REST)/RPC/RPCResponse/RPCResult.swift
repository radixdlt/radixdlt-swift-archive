//
//  RPCResult.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

internal typealias RPCResult<Model: Decodable> = Swift.Result<RPCResponse<Model>, RPCError>

extension Result: Decodable where Success: Decodable, Failure == RPCError {
    
    enum CodingKeys: String, CodingKey {
        case result, params, error
    }
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let singleValueContainer = try decoder.singleValueContainer()
        
        if keyedContainer.contains(.params) || keyedContainer.contains(.result) {
            do {
                self = .success(try singleValueContainer.decode(Success.self))
            } catch let decodingError as DecodingError {
                self = .failure(RPCError.failedToDecodeResponse(decodingError))
            } catch {
                incorrectImplementation("Covered by RPCResponse `init(from: Decoder)`")
            }
        } else if keyedContainer.contains(.error) {
            do {
                self = .failure(try singleValueContainer.decode(RPCError.self))
            } catch {
                 incorrectImplementation("Covered by RPCError `init(from: Decoder)`")
            }
        } else {
            let anyDecodable = try singleValueContainer.decode(AnyDecodable.self)
            let jsonString = String(describing: anyDecodable.value)
            self = .failure(RPCError.unrecognizedJson(jsonString: jsonString))
        }
    }
}
