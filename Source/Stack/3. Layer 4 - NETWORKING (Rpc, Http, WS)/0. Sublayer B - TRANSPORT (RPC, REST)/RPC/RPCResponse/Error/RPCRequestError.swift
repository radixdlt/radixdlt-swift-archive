//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
