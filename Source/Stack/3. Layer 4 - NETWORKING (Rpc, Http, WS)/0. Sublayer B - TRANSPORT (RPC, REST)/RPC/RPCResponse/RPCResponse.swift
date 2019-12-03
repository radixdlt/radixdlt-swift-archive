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

// swiftlint:disable colon opening_brace

/// Simple although important wrapper of *ALL* JSON-RPC responses, taking a `Model` which must conform to Decodable and decodes the
/// JSON from the RPC API. It can be on two different formats:
///
/// # Format 1 - JSON-RPC Call Response
/// Either we get a response containing a requestId (`"id"`), matching the number sent in our request. This also contains the JSON key
/// and value for `"result"`, this is the first message response of the `Atoms.subscribe` request, followed by two messages on the other
/// format.
/// ```
///     {
///         "id": 1,
///         "jsonrpc": "2.0",
///         "result": {
///             "success": true
///         }
///     }
/// ```
///
/// # Format 2 - JSON-RPC Notification
/// Here follows the second possible format of responses from the RPC API, the message lacks both `"id"` and `"result"`, instead it contains
/// `"method"` and `"params"`, just like our requests we sent. When we send a `Atoms.subscribe` request as mentioned above, the first response
/// is the previous example followed by these two messages:
/// ```
///     {
///         "jsonrpc": "2.0",
///         "method": "Atoms.subscribeUpdate",
///         "params": {
///             "atomEvents": [
///                 {
///                     "atom": { /* ATOM OMITTED FOR SAKE OF BREVITY */ },
///                     "serializer": "radix.atom",
///                     "type": ":str:store",
///                     "version": 100
///                  }
///             ],
///             "isHead": false,
///             "subscriberId": "2388888"
///         }
///     }
/// ```
///
/// Followed by the third message, also on the same format:
/// ```
///     {
///         "jsonrpc": "2.0",
///         "method": "Atoms.subscribeUpdate",
///         "params": {
///             "atomEvents": [],
///             "isHead": true,
///             "subscriberId": "1783940"
///         }
///     }
/// ```
///
internal enum RPCResponse<Model>:
    Decodable,
    RPCResponseResultConvertible
where Model: Decodable
{
    // swiftlint:enable colon opening_brace

    case fromCall(RPCCallResponse<Model>)
    case notification(RPCNotificationResponse<Model>)
}

// MARK: - RPCResponseResultConvertible
extension RPCResponse {
    var model: Model {
        switch self {
        case .fromCall(let response): return response.model
        case .notification(let response): return response.model
        }
    }
}

extension RPCResponse {
    var fromCall: RPCCallResponse<Model>? {
        guard case .fromCall(let fromCall) = self else { return nil }
        return fromCall
    }
    var notification: RPCNotificationResponse<Model>? {
        guard case .notification(let notification) = self else { return nil }
        return notification
    }
}

// MARK: - Decodable
extension RPCResponse {

    enum CodingKeys: String, CodingKey {
        case result, params
    }
    
    init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let singleValueContainer = try decoder.singleValueContainer()
        
        if keyedContainer.contains(.params) {
            do {
                self = .notification(try singleValueContainer.decode(RPCNotificationResponse<Model>.self))
            } catch let decodingError as DecodingError {
                throw decodingError
            } catch {
                incorrectImplementation("Unexpected and unhandled error trying to decode JSON into `RPCNotificationResponse`: \(error)")
            }
        } else if keyedContainer.contains(.result) {
            do {
              self = .fromCall(try singleValueContainer.decode(RPCCallResponse<Model>.self))
            } catch let decodingError as DecodingError {
                throw decodingError
            } catch {
                incorrectImplementation("Unexpected and unhandled error trying to decode JSON into `RPCCallResponse`: \(error)")
            }
        } else {
            incorrectImplementation("Error decoding `RPCResponse`, found neither json key `\(CodingKeys.result.stringValue)`, nor `\(CodingKeys.params.stringValue)`")
        }
    }
}
