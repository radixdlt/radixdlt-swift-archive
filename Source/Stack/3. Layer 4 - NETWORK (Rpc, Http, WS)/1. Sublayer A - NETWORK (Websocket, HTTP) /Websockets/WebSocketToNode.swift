//
//  WebSocketToNode.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

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
        
        self.state.subscribe(onNext: { log.debug("WS status -> `\($0)`") }).disposed(by: bag)
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
        log.warning("Deinit (might be relevant until life cycle is proper fixed)")
        closeDisregardingListeners()
    }
}

public extension WebSocketToNode {
    enum Error: Swift.Error {
        case hasDisconnected
    }
    
    func waitForConnection() -> Completable {
        return state.filter { $0.isReady }.take(1).asSingle().asCompletable().debug()
    }
    
    func sendMessage(_ message: String) {
        guard isReady else {
            queuedOutgoingMessages.append(message)
            return
        }
        print("Sending message of length: #\(message.count) chars")
        print("Sending message:\n<\(message)>")
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
    
//    var isConnected: Bool {
//        return hasStatus(.connected)
//    }

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
//        stateSubject.onNext(.connected)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Swift.Error?) {
        log.warning("Websocket closed")
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
            log.debug("Received welcome message, which we ignore, proceed sending queued")
            stateSubject.onNext(.ready)
            sendQueued()
        } else {
            log.debug("Received response over websockets (text of #\(text.count) chars)")
            print("Response just received over websocket:\n<\(text)>")
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
