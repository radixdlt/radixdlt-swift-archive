/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import Foundation
import Starscream
import RxSwift

public final class WebSocketToNode: FullDuplexCommunicationChannel, WebSocketDelegate, WebSocketPongDelegate {
    
    private let stateSubject: BehaviorSubject<WebSocketStatus>
    private let receivedMessagesSubject = PublishSubject<String>()
    
    // Received messages
    public let messages: Observable<String>
    
    private var queuedOutgoingMessages = [String]()
    
    public let state: Observable<WebSocketStatus>
    private var socket: WebSocket?
    private let bag = DisposeBag()
    internal let node: Node
    
    public init(node: Node, shouldConnect: Bool) {
        defer {
            if shouldConnect {
                connect()
            }
        }
        
        let stateSubject = BehaviorSubject<WebSocketStatus>(value: .disconnected)
        
        stateSubject.filter { $0 == .failed }
            .debounce(RxTimeInterval.seconds(60), scheduler: MainScheduler.instance)
            .subscribe(
                onNext: { _ in stateSubject.onNext(.disconnected) },
                onError: { _ in stateSubject.onNext(.disconnected) }
        ).disposed(by: bag)
        
        self.stateSubject = stateSubject
        self.node = node
        
        self.messages = receivedMessagesSubject.asObservable()
        self.state = stateSubject.asObservable()
        
        self.state.subscribe(onNext: { log.verbose("WS status -> `\($0)`") }).disposed(by: bag)
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
    
    func waitForConnection() -> Completable {
        return state.filter { $0.isReady }.take(1).asSingle().asCompletable()
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
        guard !receivedMessagesSubject.hasObservers else { return false }
        closeDisregardingListeners()
        return true
    }
    
    func connect() {
        let status = try? stateSubject.value()
        switch status {
        case .none, .disconnected?, .failed?:
            stateSubject.onNext(.connecting)
            socket = createSocket(shouldConnect: true)
        case .closing?, .connecting?, .ready?: return
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
        stateSubject.onNext(.closing)
        socket?.disconnect()
    }

    func hasStatus(_ status: WebSocketStatus) -> Bool {
        do {
            return try stateSubject.value() == status
        } catch {
            return false
        }
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
        log.info("Websocket closed")
        guard !isClosing else {
            self.socket = nil
            return stateSubject.onNext(.disconnected)
        }
        if error != nil {
            self.socket = nil
            stateSubject.onNext(.failed)
        } else {
            stateSubject.onNext(.disconnected)
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if text.contains("Radix.welcome") {
            log.verbose("Received welcome message, which we ignore, proceed sending queued")
            stateSubject.onNext(.ready)
            sendQueued()
        } else {
            log.debug("Received response over websockets (text of #\(text.count) chars)")
            log.verbose("Received response over websockets: \n<\(text)>\n")
            receivedMessagesSubject.onNext(text)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        log.info("Socket did receive data.")
    }
    
    func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
        log.info("Socket got pong")
    }
    
}
