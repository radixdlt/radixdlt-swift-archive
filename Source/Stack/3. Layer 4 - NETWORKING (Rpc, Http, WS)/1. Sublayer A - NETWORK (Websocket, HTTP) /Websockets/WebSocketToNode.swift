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
import Starscream
import Combine

public final class WebSocketToNode: FullDuplexCommunicationChannel, WebSocketDelegate, WebSocketPongDelegate {
    
    private let stateSubject: CurrentValueSubjectNoFail<WebSocketStatus>
    private let receivedMessagesSubject = PassthroughSubjectNoFail<String>()
    
    // Received messages
    public let messages: CombineObservable<String>
    
    private var queuedOutgoingMessages = [String]()
    
    public let state: CombineObservable<WebSocketStatus>
    private var socket: WebSocket?
    private var cancellables = Set<AnyCancellable>()
    internal let node: Node
    
    public init(node: Node, shouldConnect: Bool) {
        defer {
            if shouldConnect {
                connect()
            }
        }
        
        let stateSubject = CurrentValueSubjectNoFail<WebSocketStatus>(.disconnected)
        
//        stateSubject.filter { $0 == .failed }
//            .debounce(RxTimeInterval.seconds(60), scheduler: MainScheduler.instance)
//            .subscribe(
//                onNext: { _ in stateSubject.send(.disconnected) },
//                onError: { _ in stateSubject.send(.disconnected) }
//        ).store(in: &cancellables)
        combineMigrationInProgress()
        
        self.stateSubject = stateSubject
        self.node = node
        
        self.messages = receivedMessagesSubject.eraseToAnyPublisher()
        self.state = stateSubject.eraseToAnyPublisher()
        
        self.state.sink(
            receiveValue: { log.verbose("WS status -> `\($0)`") }
        ).store(in: &cancellables)
    }
    
    private func createSocket(shouldConnect: Bool) -> WebSocket {
        let newSocket: WebSocket
        defer {
            newSocket.delegate = self
            if shouldConnect {
                newSocket.connect()
            }
        }
        newSocket = WebSocket(url: node.websocketsUrl.url)
        return newSocket
    }
    
    deinit {
        closeDisregardingListeners()
    }
}

public extension WebSocketToNode {
    enum Error: Swift.Error {
        case hasDisconnected
    }
    
    func waitForConnection() -> CombineCompletable {
//        return state.filter { $0.isReady }.take(1).asSingle().asCompletable()
        combineMigrationInProgress()
    }
    
    func sendMessage(_ message: String) {
        guard isReady else {
            queuedOutgoingMessages.append(message)
            return
        }
        log.verbose("Sending message of length: #\(message.count) chars")
        log.verbose("Sending message:\n<\(message)>")
        socket?.write(string: message)
    }
    
    /// Close the websocket only if no it has no observers, returns `true` if it was able to close, otherwise `false`.
    @discardableResult
    func closeIfNoOneListens() -> Bool {
//        guard !receivedMessagesSubject.hasObservers else { return false }
//        closeDisregardingListeners()
//        return true
 
        combineMigrationInProgress()
    }
    
    func connect() {
        switch stateSubject.value {
        case .disconnected, .failed:
            stateSubject.send(.connecting)
            socket = createSocket(shouldConnect: true)
        case .closing, .connecting, .ready: return
        }
        
    }
}

public extension WebSocketToNode {
    var isReady: Bool {
        return hasStatus(.ready)
    }
}

private extension WebSocketToNode {
    var hasDisconnected: Bool {
        return hasStatus(.disconnected)
    }
    
    var isClosing: Bool {
        return hasStatus(.closing)
    }
    
    func closeDisregardingListeners() {
        stateSubject.send(.closing)
        socket?.disconnect()
    }

    func hasStatus(_ status: WebSocketStatus) -> Bool {
        stateSubject.value == status
    }
    
    func sendQueued() {
        queuedOutgoingMessages.forEach {
            self.sendMessage($0)
        }
        queuedOutgoingMessages = []
    }
}

public extension WebSocketToNode {
    func websocketDidConnect(socket: WebSocketClient) {
        log.verbose("Websocket did connect, to node: \(node)")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Swift.Error?) {
        log.debug("Websocket closed")
        guard !isClosing else {
            self.socket = nil
            return stateSubject.send(.disconnected)
        }
        if error != nil {
            self.socket = nil
            stateSubject.send(.failed)
        } else {
            stateSubject.send(.disconnected)
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if text.contains("Radix.welcome") {
            log.verbose("Received welcome message, which we ignore, proceed sending queued")
            stateSubject.send(.ready)
            sendQueued()
        } else {
            log.debug("Received response over websockets (text of #\(text.count) chars)")
            log.verbose("Received response over websockets: \n<\(text)>\n")
            receivedMessagesSubject.send(text)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        log.info("Socket did receive data.")
    }
    
    func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
        log.info("Socket got pong")
    }
    
}
