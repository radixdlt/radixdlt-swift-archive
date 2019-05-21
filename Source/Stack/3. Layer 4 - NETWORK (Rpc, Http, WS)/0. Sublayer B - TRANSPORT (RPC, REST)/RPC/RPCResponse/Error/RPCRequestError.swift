//
//  RPCRequestError.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable opening_brace

public struct RPCRequestError: Swift.Error,
    Decodable,
    Equatable,
    CustomStringConvertible
{
    // swiftlint:enable opening_brace
    
    public let code: RPCErrorCode
    public let message: String
    public let radixErrorInfo: SubscriptionError?
}

// MARK: - Decodable
public extension RPCRequestError {
    
    enum CodingKeys: String, CodingKey {
        case code, message
        case radixErrorInfo = "data"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(RPCErrorCode.self, forKey: .code)
        message = try container.decode(String.self, forKey: .message)
        radixErrorInfo = try? container.decode(SubscriptionError.self, forKey: .radixErrorInfo)
    }
}

// MARK: - CustomStringConvertible
public extension RPCRequestError {
    var description: String {
        var radixInfoString = ""
        if let radixErrorInfo = radixErrorInfo {
            radixInfoString = ", info: '\(radixErrorInfo)'"
        }
        return """
            RPC error '\(code)' - '\(message)'\(radixInfoString)
        """
    }
}
