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

public final class WebSocketToNode: PersistentChannel, WebSocketDelegate, WebSocketPongDelegate {
    
    private let stateSubject: BehaviorSubject<WebSocketStatus>
    private let receivedMessagesSubject = PublishSubject<String>()
    
    // Received messages
    public let messages: Observable<String>
    
    private var queuedOutgoingMessages = [String]()
    
    public let state: Observable<WebSocketStatus>
    private var socket: WebSocket?
    private let bag = DisposeBag()
    internal let node: Node
    
    // swiftlint:disable:next function_body_length
    public init(node: Node, shouldConnect: Bool = true) {
        defer {
            if shouldConnect {
                connect()
            }
        }
        
        let state = BehaviorSubject<WebSocketStatus>(value: .disconnected)
        
        state.filter { $0 == .failed }
            .debounce(60, scheduler: MainScheduler.instance)
            .subscribe(
                onNext: { _ in state.onNext(.disconnected) },
                onError: { _ in state.onNext(.disconnected) }
            ).disposed(by: bag)
        
        self.stateSubject = state
        self.node = node
        
        self.messages = receivedMessagesSubject.asObservable()
        self.state = stateSubject.asObservable()
        
        self.state.subscribe(onNext: { log.info("WS status -> `\($0)`") }).disposed(by: bag)
    }
    
    private func createSocket(shouldConnect: Bool) -> WebSocket {
        let newSocket: WebSocket
        defer {
            newSocket.delegate = self
            if shouldConnect {
                newSocket.connect()
            }
        }
        newSocket = WebSocket(url: node.url)
        return newSocket
    }
    
    deinit {
        log.warning("Deinit (might be relevant until life cycle is proper fixed)")
        close()
    }
}

public extension WebSocketToNode {
    enum Error: Swift.Error {
        case hasDisconnected
    }
    
    func sendMessage(_ message: String) {
        guard isConnected else {
            queuedOutgoingMessages.append(message)
            return
        }
        socket?.write(string: message)
    }
    
    func close() {
        socket?.disconnect()
    }
    
    func connect() {
        let status = try? stateSubject.value()
        switch status {
        case .none, .disconnected?, .failed?:
            stateSubject.onNext(.connecting)
            socket = createSocket(shouldConnect: true)
        case .closing?, .connected?, .connecting?: return
        }
        
    }
}

private extension WebSocketToNode {
    var hasDisconnected: Bool {
        return hasStatus(.disconnected)
    }
    
    var isClosing: Bool {
        return hasStatus(.closing)
    }
    
    var isConnected: Bool {
        return hasStatus(.connected)
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
            log.verbose("Sending queued message:\n\"\"\"\($0)\n\"\"\"\n")
            self.sendMessage($0)
        }
        queuedOutgoingMessages = []
    }
}

public extension WebSocketToNode {
    func websocketDidConnect(socket: WebSocketClient) {
        stateSubject.onNext(.connected)
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
            log.verbose("Received welcome message, which we ignore, proceed sending queued")
            sendQueued()
        } else {
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
