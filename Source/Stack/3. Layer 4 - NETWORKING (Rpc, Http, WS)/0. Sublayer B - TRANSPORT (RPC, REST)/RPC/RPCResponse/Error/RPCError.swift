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

public enum RPCError: Swift.Error, Decodable, Equatable, CustomStringConvertible {
    case requestError(RPCRequestError)
    
    /// Received response containing `"params"` or `"result"`, thus a valid response, but failed to decode it into a model.
    case failedToDecodeResponse(error: DecodingError, toType: Decodable.Type, fromJson: String) // Instantiated from RPCResult
    
    case unrecognizedJson(jsonString: String)
    
    /// Received error from API, but failed to decode the error itself => "metaError"
    case metaError(DecodingError)
}

public extension RPCError {
    static func requestErrorCode(_ code: RPCErrorCode) -> RPCError {
        return .requestError(.code(code))
    }
    
    static func subscriberIdAlreadyInUse(_ subscriberId: SubscriberId) -> RPCError {
        return .requestError(RPCRequestError.subscriberIdAlreadyInUse(subscriberId))
    }
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

// MARK: - CustomStringConvertible
public extension RPCError {
    var description: String {
        switch self {
        case .failedToDecodeResponse(let decodingError, let decodableType, let fromJson): return "Received non error response from API, but failed to decode it into type: <\(decodableType)>, decoding error: <\(decodingError)>, from json: <\(fromJson)>"
        case .metaError(let decodingError): return "Received specific API error, but failed to parse it, meta error: \(decodingError)"
        case .unrecognizedJson(let jsonString): return "Error parsing unrecognized json: `\(jsonString)`"
        case .requestError(let requestError): return "Request error: `\(requestError)`"
        }
    }
}

// MARK: - Equatable
public extension RPCError {
    static func == (lhs: RPCError, rhs: RPCError) -> Bool {
        return RPCError.compare(lhs: lhs, rhs: rhs)
    }
    
    static func compare(lhs: RPCError, rhs: RPCError, unrecognizedJsonComparer: (String, String) -> Bool = { _, _ in return true}) -> Bool {
        switch (lhs, rhs) {
        case (.requestError(let lhsRequestError), .requestError(let rhsRequestError)):
            return lhsRequestError == rhsRequestError
        case (.failedToDecodeResponse(let lhsDecodingError, let lhsDecodableType, _), .failedToDecodeResponse(let rhsDecodingError, let rhsDecodableType, _)):
            return lhsDecodableType == rhsDecodableType && lhsDecodingError == rhsDecodingError
        case (.metaError(let lhsDecodingError), .metaError(let rhsDecodingError)):
            return lhsDecodingError == rhsDecodingError
        case (.unrecognizedJson(let lhsJsonString), .unrecognizedJson(let rhsJsonString)):
            return unrecognizedJsonComparer(lhsJsonString, rhsJsonString)
        default: return false
        }
    }
}
