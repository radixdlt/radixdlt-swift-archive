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
    public let message: String?
    public let radixErrorInfo: SubscriptionError?
    
    public init(code: RPCErrorCode, message: String? = nil, info: SubscriptionError? = nil) {
        self.code = code
        self.message = message
        self.radixErrorInfo = info
    }
}

public extension RPCRequestError {
    static func code(_ errorCode: RPCErrorCode) -> RPCRequestError {
        return RPCRequestError(code: errorCode)
    }
    
    static func subscriberIdAlreadyInUse(_ subscriberId: SubscriberId) -> RPCRequestError {
         return RPCRequestError(code: .serverError, message: "Subscriber + \(subscriberId) already exists.")
    }
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
            radixInfoString = ", info: \(radixErrorInfo)"
        }
        var messageString = ""
        if let message = message {
            messageString = ": \"\(message)\""
        }
        return "\(code.nameAndCode)\(messageString)\(radixInfoString)"
    }
}

public extension RPCRequestError {
    static func == (lhs: RPCRequestError, rhs: RPCRequestError) -> Bool {
        let codesMatches = lhs.code == rhs.code
        let messagesMatches: Bool = {
            switch (lhs.message, rhs.message) {
            case (.some(let lhsMessage), .some(let rhsMessage)): return lhsMessage == rhsMessage
            case (.none, .none): return true
            case (.some, .none): return false
            case (.none, .some): return false
            }
        }()
        
        return codesMatches && messagesMatches
    }
}

private extension RPCErrorCode {
    var nameAndCode: String {
        return "\(self) (\(rawValue))"
    }
}
