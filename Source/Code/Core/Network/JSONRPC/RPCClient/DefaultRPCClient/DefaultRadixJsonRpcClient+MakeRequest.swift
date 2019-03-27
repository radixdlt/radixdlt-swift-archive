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
    
    func makeRequest<Request, Response>(_ request: Request) -> Observable<Response> where Request: JSONRPCKit.Request, Response == Request.Response, Response: RadixModelTypeStaticSpecifying {
        
        let batch = rpcRequestFactory.create(request)
        let requestId = batch.requestId
        let jsonString = batch.jsonString
        
        channel.sendMessage(jsonString)
        
        return channel.responseForMessage(with: requestId)
    }
}

private struct JSONKey {
    static let result = "result"
    static let id = "id"
    static let method = "method"
}

private let jsonRpcMethodForWelcomeMessage = "Radix.welcome"

extension PersistentChannel {
    func responseForMessage<Response>(with requestId: Int) -> Observable<Response> where Response: Decodable & RadixModelTypeStaticSpecifying {
        return messages.map {
            $0.data(using: .utf8)!
        }.map { responseData -> Data? in
                let json = try! JSONSerialization.jsonObject(with: responseData, options: []) as! JSON
                guard (json[JSONKey.method] as? String) != jsonRpcMethodForWelcomeMessage else { return nil }
                let requestIdInResponse = json[JSONKey.id] as! Int
                guard requestIdInResponse == requestId else {
                    print("Filtering out request")
                    return nil
                }
                
                guard let result = json[JSONKey.result] else {
                    print("'\(JSONKey.result)' in JSONRPC response was empty")
                    return nil
                }
                
                let responseJson = try! JSONSerialization.data(withJSONObject: result, options: [])
                return responseJson
            }.filterNil()
            .map {
                try! RadixJSONDecoder().decode(Response.self, from: $0)
        }
    }
}

extension JSONRPCKit.Batch1 {
    var requestId: Int {
        guard let requestIdEnum = batchElement.id else {
            incorrectImplementation("Should have a request Id")
        }
        switch requestIdEnum {
        case .number(let requestIdInteger): return requestIdInteger
        case .string: incorrectImplementation("Please use Integers")
        }
    }
    
    var jsonString: String {
        let encoder = RadixJSONEncoder()
        let data = try! encoder.encode(self)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            incorrectImplementation("Should always be able to get string from JSON")
        }
        return jsonString
    }
}

// swiftlint:enable:all
