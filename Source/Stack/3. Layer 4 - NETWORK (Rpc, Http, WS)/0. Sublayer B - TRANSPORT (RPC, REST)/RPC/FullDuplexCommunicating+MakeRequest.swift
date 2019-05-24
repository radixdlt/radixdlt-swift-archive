//
//  RPCClient+MakeRequest.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

// MARK: - MakeRequest
internal extension FullDuplexCommunicating {
    
    func makeRequest<ResultFromResponse>(method: RPCMethod) -> Observable<ResultFromResponse> where ResultFromResponse: Decodable {
       
        let rpcRequest = RPCRequest(method: method)
        let message = rpcRequest.jsonString
        let requestId = rpcRequest.requestId
        
        return channel.responseForMessage(with: requestId)
            .do(onSubscribed: {
                self.channel.sendMessage(message)
            })
    }
}

private extension RPCRequest {
    var jsonString: String {
        do {
            let data = try RadixJSONEncoder().encode(self)
            return String(data: data)
        } catch {
            incorrectImplementation("Should be able to encode `self` to JSON string")
        }
    }
}
