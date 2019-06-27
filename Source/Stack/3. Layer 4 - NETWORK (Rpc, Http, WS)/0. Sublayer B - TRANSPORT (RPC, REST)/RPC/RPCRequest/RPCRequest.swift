//
//  RPCRequest.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct RPCRequest: Encodable {
    public let rpcMethod: String
    private let _encodeParams: RPCMethod.EncodeValue<CodingKeys>
    public let requestId: Int
    public let version = "2.0"
    
    public init(rpcMethod: String, encodeParams: @escaping RPCMethod.EncodeValue<CodingKeys>) {
        self.rpcMethod = rpcMethod
        self._encodeParams = encodeParams
        self.requestId = RequestIdGenerator.nextId()
    }
}

// MARK: - Convenience Init
public extension RPCRequest {
    init(rootRequest: RPCRootRequest) {
        switch rootRequest {
        case .fireAndForget(let rpcMethod): self.init(method: rpcMethod)
        case .sendAndListenToNotifications(let rpcMethod, _): self.init(method: rpcMethod)
        }
    }
}

private extension RPCRequest {
    
    init(method: RPCMethod) {
        self.init(rpcMethod: method.method.rawValue, encodeParams: method.encodeParams(key: .parameters))
    }
}

// MARK: - Encodable
public extension RPCRequest {
    enum CodingKeys: String, CodingKey {
        case requestId = "id"
        case rpcMethod = "method"
        case parameters = "params"
        case version = "jsonrpc"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(requestId, forKey: .requestId)
        try container.encode(rpcMethod, forKey: .rpcMethod)
        try _encodeParams(&container)
        try container.encode(version, forKey: .version)
        
    }
}
