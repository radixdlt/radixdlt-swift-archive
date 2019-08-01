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

public struct RPCRequest: Encodable {
    public let rpcMethod: String
    private let _encodeParams: RPCMethod.EncodeValue<CodingKeys>
    public let requestUuid: String
    public let version = "2.0"
    
    public init(rpcMethod: String, requestUuid: UUID, encodeParams: @escaping RPCMethod.EncodeValue<CodingKeys>) {
        self.rpcMethod = rpcMethod
        self._encodeParams = encodeParams
        self.requestUuid = requestUuid.uuidString
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
    
    init(method: RPCMethod, requestUuid: UUID = .init()) {
        self.init(
            rpcMethod: method.method.rawValue,
            requestUuid: requestUuid,
            encodeParams: method.encodeParams(key: .parameters)
        )
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
        try container.encode(requestUuid, forKey: .requestId)
        try container.encode(rpcMethod, forKey: .rpcMethod)
        try _encodeParams(&container)
        try container.encode(version, forKey: .version)
        
    }
}
