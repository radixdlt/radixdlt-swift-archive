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
import Combine

extension FullDuplexCommunicationChannel {
    
    func responseOrErrorForMessage<Model>(requestId: String) -> AnyPublisher<Model, Never> where Model: Decodable {
        addListener(decodeAs: RPCCallResponse<Model>.self, identifier: requestId)
            .filter { $0.id == requestId }
            .map { $0.result }
            .eraseToAnyPublisher()
    }
    
    func observeNotification<Model>(
        _ method: RPCNotificationMethod,
        subscriberId: SubscriberId
    ) -> AnyPublisher<Model, Never> where Model: Decodable {
        addListener(decodeAs: RPCNotificationResponse<Model>.self, identifier: subscriberId.value)
            .filter { $0.subscriberId == subscriberId }
            .filter { $0.method == method }
            .map { $0.params }
            .eraseToAnyPublisher()
        
    }
}

private extension FullDuplexCommunicationChannel {
    
    func addListener<RPCTopLevelResponse: Decodable>(
        decodeAs _: RPCTopLevelResponse.Type,
        identifier: String
    ) -> AnyPublisher<RPCTopLevelResponse, Never> {
        
        let messageSubject = PassthroughSubject<String, Never>()
        let removeListener = addListener(messageSubject, forKey: ListenerKey(UUID.init()))

        return messageSubject
            .flatMap { webSocketMessage -> AnyPublisher<RPCTopLevelResponse, Never> in
                do {
                    let data = webSocketMessage.toData()
                    let decoded = try JSONDecoder().decode(RPCTopLevelResponse.self, from: data)
                    return Just(decoded).eraseToAnyPublisher()
                } catch {
                    if webSocketMessage.contains(identifier) {
                        Swift.print("\n\n⚡️Suppressed error when decoding \(RPCTopLevelResponse.self)\n\nError: \(error)\n\nFrom json:\n<\n\(webSocketMessage)\n>\n")
                    }
                    return Empty<RPCTopLevelResponse, Never>(completeImmediately: false)
                        .eraseToAnyPublisher()
                }
            }
            .handleEvents(
//                receiveOutput: { Swift.print("✅ rpc model over ws: \($0)") },
                receiveCompletion: { _ in removeListener() },
                receiveCancel: { removeListener() }
            )
            .subscribe(on: RadixSchedulers.mainThreadScheduler)
            .receive(on: RadixSchedulers.backgroundScheduler)
            .eraseToAnyPublisher()
    }
}
