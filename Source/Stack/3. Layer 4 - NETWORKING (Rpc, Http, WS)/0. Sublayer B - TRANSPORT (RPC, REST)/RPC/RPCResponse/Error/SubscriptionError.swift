/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

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
