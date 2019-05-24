//
//  SubscriptionError.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable opening_brace

public struct SubscriptionError: Swift.Error,
    Decodable,
    Equatable,
    CustomStringConvertible
{

    // swiftlint:enable opening_brace

    public let radixErrorCode: RadixErrorCode
    public let message: String
    public let extra: [String: Any]?
  
}

// MARK: - Equatable
public extension SubscriptionError {
    static func == (lhs: SubscriptionError, rhs: SubscriptionError) -> Bool {
        let extraMatch: Bool = {
            switch (lhs.extra, rhs.extra) {
            case (.some, .some): return true
            case (.none, .none): return true
            default: return false
            }
        }()
        return lhs.radixErrorCode == rhs.radixErrorCode && lhs.message == rhs.message && extraMatch
    }
}

// MARK: - Decodable
public extension SubscriptionError {
    enum CodingKeys: String, CodingKey {
        case radixErrorCode = "radix_code"
        case message        = "radix_message"
        case extra          = "radix_data"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        radixErrorCode = try container.decode(RadixErrorCode.self, forKey: .radixErrorCode)
        message = try container.decode(String.self, forKey: .message)
        extra = try? container.decode([String: Any].self, forKey: .extra)
    }
}

// MARK: - CustomStringConvertible
public extension SubscriptionError {
    var description: String {
        var extraString = ""
        if let extra = extra {
            extraString = ", extra: \(extra)"
        }
        return """
            Radix error \(radixErrorCode) - \(message)\(extraString)
        """
    }
}
