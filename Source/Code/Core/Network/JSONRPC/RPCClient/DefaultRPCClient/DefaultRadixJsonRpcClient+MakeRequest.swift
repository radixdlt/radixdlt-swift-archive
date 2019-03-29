//
//  DefaultRadixJsonRpcClient+MakeRequest.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-27.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift
import JSONRPCKit

// swiftlint:disable all
// THIS IS A PROOF OF CONCEPT that well be refactored
internal extension DefaultRadixJsonRpcClient {
    
    func makeRequest<Request, Response>(_ request: Request) -> Observable<Response> where Request: JSONRPCKit.Request, Response == Request.Response {
        let batch = rpcRequestFactory.create(request)
        let requestId = batch.requestId
        let jsonString = batch.jsonString
        channel.sendMessage(jsonString)
        
        return channel.responseForMessage(with: requestId)
    }
}

extension PersistentChannel {
    func responseForMessage<Response>(with requestId: Int) -> Observable<Response> where Response: Decodable {
        return messages
            .map { $0.toData() }
            .map { data -> JSONRPCResponse<Response>? in
                do {
                    return try JSONDecoder().decode(JSONRPCResponse<Response>.self, from: data)
                } catch {
                    log.error(error)
                    return nil
                }
            }.filterNil()
            .map { response -> JSONRPCResponse<Response>? in
                // If response contains id, filter on it
                if let requestIdInResponse = response.requestId, requestIdInResponse != requestId {
                    return nil
                }
                return response
            }.filterNil()
            .map { $0.resultOrParam }
    }
}

/// Simple although important wrapper of _ALL_ JSON-RPC responses, taking a `Result` which must conform to Decodable and decodes the
/// JSON from the RPC API. It can be on two different formats:
///
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
/// Here follows the second possible format of responses from the RPC API, the message lacks both `"id"` and `"result"`, instead it contains
/// `"method"` and `"params"`, just like our requests we sent. When we send a `Atoms.subscribe` request as mentioned above, the first response
/// is the previous example followed by these two messages:
/// ```
///     {
///         "jsonrpc": "2.0",
///         "method": "Atoms.subscribeUpdate",
///         "params": {
///             "atomEvents": [
///             {
///             "atom": { /* ATOM OMITTED FOR SAKE OF BREVITY */ },
///             "serializer": -1784097847,
///             "type": ":str:store",
///             "version": 100
///             }
///             ],
///             "isHead": false,
///             "subscriberId": "2388888"
///         }
///     }
/// ```
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
/// Another example of such a message, lacking `"result"` and `"id"` but containing `"params"` and `"method"` is
/// The absolute first message received from the RPC API over webscoket, nameley the `Radix.welcome` message, which looks like this:
/// ```
///     {
///         "jsonrpc": "2.0",
///         "method": "Radix.welcome",
///         "params": {
///             "message": "Hello!"
///         }
///     }
/// ```
/// It is important to note that this message SHOULD have been filtered out by the Websocket code, i.e. the RCP client code
/// should not have to care about this message.
private struct JSONRPCResponse<ResultOrParam>: Decodable where ResultOrParam: Decodable {
    let resultOrParam: ResultOrParam
    let requestId: Int?
    let method: String?
}

extension JSONRPCResponse {
    enum CodingKeys: String, CodingKey {
        case result
        case params
        case method
        case requestId = "id"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        requestId = try container.decodeIfPresent(Int.self, forKey: .requestId)
        method = try container.decodeIfPresent(String.self, forKey: .method)
        
        do {
            self.resultOrParam =  try container.decode(ResultOrParam.self, forKey: .result)
        } catch {
            self.resultOrParam =  try container.decode(ResultOrParam.self, forKey: .params)
        }
    }
}

// swiftlint:enable:all
