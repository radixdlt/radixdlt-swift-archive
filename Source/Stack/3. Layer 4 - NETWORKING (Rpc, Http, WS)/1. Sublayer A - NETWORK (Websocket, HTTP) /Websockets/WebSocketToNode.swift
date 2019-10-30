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

// TODO replace Starscream with Apple's `URLSessionWebSocketTask` introduced in iOS 13: https://developer.apple.com/documentation/foundation/urlsessionwebSockettask
import Starscream

import Combine
import Entwine

// swiftlint:disable colon opening_brace

public final class WebSocketToNode:
    FullDuplexCommunicationChannel,
    WebSocketDelegate,
    WebSocketPongDelegate
{
    // swiftlint:enable colon opening_brace
    
    // MARK: Primary Properties
    
    /// The Radix Node of the webSocket
    internal let node: Node
    
    /// The pending webSocket to the `node`
    private var socket: WebSocket?
    
    // MARK: Public Properties

    /// Messages received over webSockets, required by `FullDuplexCommunicationChannel`
    public let messages: AnyPublisher<String, Never>
    
    public let webSocketStatus: AnyPublisher<WebSocketStatus, Never>

    // MARK: Private Properties
    private let stateSubject: CurrentValueSubject<WebSocketStatus, Never>
    
    private let receivedMessagesSubject = PassthroughSubject<String, Never>()
    
    private var queuedOutgoingMessages = [String]()
    private var cancellables = Set<AnyCancellable>()
    
    public init(node: Node) {
        
        let stateSubject = CurrentValueSubject<WebSocketStatus, Never>(.disconnected)
        
        //        stateSubject.filter { $0 == .failed }
        //            .debounce(RxTimeInterval.seconds(60), scheduler: MainScheduler.instance)
        //            .subscribe(
        //                onNext: { _ in stateSubject.send(.disconnected) },
        //                onError: { _ in stateSubject.send(.disconnected) }
        //        ).store(in: &cancellables)
        
        logBroken()
        
        self.stateSubject = stateSubject
        self.node = node
        
        self.messages = receivedMessagesSubject.eraseToAnyPublisher()
        self.webSocketStatus = stateSubject.eraseToAnyPublisher()
        
        self.webSocketStatus.sink(
            receiveValue: { log.verbose("WS status -> `\($0)`") }
        ).store(in: &cancellables)
    }
    
    deinit {
        closeDisregardingListeners()
    }
}

// MARK: Public
public extension WebSocketToNode {
    
    func sendMessage(_ message: String) {
        guard isConnected else {
            queuedOutgoingMessages.append(message)
            return
        }
        log.verbose("Sending message of length: #\(message.count) chars")
        log.verbose("Sending message:\n<\(message)>")
        socket?.write(string: message)
    }
    
    /// Close the webSocket only if no it has no observers, returns `true` if it was able to close, otherwise `false`.
    @discardableResult
    func closeIfNoOneListens() -> Bool {
        //        guard !receivedMessagesSubject.hasObservers else { return false }
        //        closeDisregardingListeners()
        //        return true
        
        combineMigrationInProgress()
    }
    
    @discardableResult
    func connectAndNotifyWhenConnected() -> Future<Void, Never> {
        switch stateSubject.value {
        case .disconnected, .failed:
            stateSubject.send(.connecting)
            socket = createAndConnectToSocket()
        case .closing, .connecting, .connected: break
        }
        
        return webSocketStatus.filter { $0.isConnected }
            .first()
            .ignoreOutput()
            .asFuture()
    }
}

// MARK: WebSocketDelegate
// It is unfortunate that StarScream decided to spell out `webSocket` like `websocket` in their prefix of their delegate methods.
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
            stateSubject.send(.connected) // Connected and ready to read messages from, since we have discarded this first Welcome message
            sendQueued()
        } else {
            log.debug("Received response over webSockets (text of #\(text.count) chars)")
            log.verbose("Received response over webSockets: \n<\(text)>\n")
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

// MARK: - Private

// MARK: Status
private extension WebSocketToNode {
    
    var isDisconnected: Bool {
        return hasStatus(.disconnected)
    }
    
    var isClosing: Bool {
        return hasStatus(.closing)
    }
    
    var isConnected: Bool {
        return hasStatus(.connected)
    }
    
    func hasStatus(_ status: WebSocketStatus) -> Bool {
        stateSubject.value == status
    }
}

// MARK: Helpers
private extension WebSocketToNode {
    func sendQueued() {
        queuedOutgoingMessages.forEach {
            self.sendMessage($0)
        }
        queuedOutgoingMessages = []
    }
    
    func closeDisregardingListeners() {
        stateSubject.send(.closing)
        socket?.disconnect()
    }
    
    func createAndConnectToSocket() -> WebSocket {
        let newSocket = WebSocket(url: node.webSocketsUrl.url)
        newSocket.delegate = self
        newSocket.connect()
        return newSocket
    }
}
