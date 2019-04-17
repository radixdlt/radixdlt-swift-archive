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
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = .success(try container.decode(Success.self))
        } catch {
            self = .failure(try container.decode(RPCError.self))
        }
    }
}

extension RPCResult: PotentiallyRequestIdentifiable where Success: RPCResposeResultConvertible {
    var requestIdIfPresent: Int? {
        switch self {
        case .success(let success): return success.requestIdIfPresent
        case .failure: return nil
        }
    }
}
