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

extension PersistentChannel {
    func responseForMessage<Response>(with requestId: Int) -> Observable<Response> where Response: Decodable & RadixModelTypeStaticSpecifying {
        return messages.map { jsonString -> Data? in
            guard !jsonString.contains(
                """
                    "method":"\(jsonRpcMethodForWelcomeMessage)"
                """
            ) else { return nil }
            let json = jsonString.data(using: .utf8)!
            print(jsonString)
            return json
        }.filterNil()
        .map { data -> JSONRPCResponse<Response>? in
            do {
                return try JSONDecoder().decode(JSONRPCResponse<Response>.self, from: data)
            } catch {
                print("⚠️ error: \(error)")
                return nil
            }
        }.filterNil()
            .filter { $0.requestId == requestId }
        .map { $0.result }
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

private enum JSONRPCResponseCodingKeys: String, CodingKey {
    case result
    case method
    case requestId = "id"
}

private struct JSONRPCResponse<Result>: Decodable where Result: Decodable {
    
    let result: Result
    let requestId: Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONRPCResponseCodingKeys.self)
        requestId = try container.decode(Int.self, forKey: .requestId)
        result = try container.decode(Result.self, forKey: .result)
    }
}

private let jsonRpcMethodForWelcomeMessage = "Radix.welcome"

// swiftlint:enable:all
