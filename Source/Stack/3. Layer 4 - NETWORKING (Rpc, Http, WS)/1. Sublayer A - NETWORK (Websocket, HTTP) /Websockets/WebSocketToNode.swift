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
import Entwine

// swiftlint:disable colon opening_brace

public final class WebSocketToNode:
    NSObject, // `URLSessionWebSocketDelegate` requires `NSObject` 😢
    FullDuplexCommunicationChannel,
    URLSessionWebSocketDelegate
{
    // swiftlint:enable colon opening_brace
    
    // MARK: Primary Properties
    
    /// The Radix Node of the webSocket
    internal let node: Node
    
    /// The pending webSocket to the `node`
    private var webSocketTask: URLSessionWebSocketTask?
    
    // MARK: Private Properties
    private let webSocketStatusSubject: CurrentValueSubject<WebSocketStatus, Never>
    
    private lazy var urlSession = URLSession(
        configuration: .default,
        delegate: self,
        delegateQueue: OperationQueue.main
    )
    
    private var listeners = [UUID: Listener]()
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var dispatchQueue = DispatchQueue(
        label: "com.radixdlt.ws-to-node-\(node.webSocketsUrl.url.absoluteURL)",
        qos: .utility,
        target: nil
    )
    
    internal init(
        node: Node,
        webSocketStatusSubject: CurrentValueSubject<WebSocketStatus, Never> = .init(.disconnected)
    ) {
        self.webSocketStatusSubject = webSocketStatusSubject
        self.node = node
    }
    
    deinit {
        closeDisregardingListeners(closeCode: .goingAway)
    }
}

// MARK: Public
public extension WebSocketToNode {
    
    var webSocketStatus: AnyPublisher<WebSocketStatus, Never> {
        webSocketStatusSubject
            .eraseToAnyPublisher()
    }
    
    @discardableResult
    func close(strategy: WebSocketClosingStrategy = .ifInUseSkipClosing) -> CloseWebSocketResult {
        if strategy == .ifInUseSkipClosing && listeners.count > 0 {
            return .didNotClose(reason: .isInUse)
        }
        closeDisregardingListeners(closeCode: .normalClosure)
        return .closed
    }
    
    @discardableResult
    func connectAndNotifyWhenConnected() -> Future<WebSocketToNode, Never> {
        createAndConnectToSocketIfNeeded()
        
        return Future<WebSocketToNode, Never> { [unowned self] promise in
            self.webSocketStatus.filter { $0.isConnected }
                .first()
                .ignoreOutput()
                .sink { promise(.success(self)) }
                .store(in: &self.cancellables)
        }
    }
}

// MARK: WebSocketToNode
public extension WebSocketToNode {
    
    func sendMessage(_ message: String) {
        guard isConnected else { return }
        
        webSocketTask?.send(.string(message)) { error in
            if let error = error {
                // TODO forward errors to listener?
                print("🔌☢️ Failed to send message, error: \(error)")
            }
        }
    }
    
    func addListener(_ listener: Listener) -> RemoveListener {
        let key = UUID()
        self.syncronize { [weak self] in
            guard let nonWeakSelf = self else { return }
            nonWeakSelf.listeners[key] = listener
        }
        
        return { [unowned self] in
            self.syncronize { [weak self] in
                guard let nonWeakSelf = self else { return }
                nonWeakSelf.listeners.removeValue(forKey: key)
            }
        }
    }
}

// MARK: URLSessionWebSocketDelegate
public extension WebSocketToNode {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        changeStatus(to: .connected)
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        
        defer { tearDown() }
        
        switch closeCode {
        case .goingAway, .normalClosure:
            guard !isClosing else { return }
            changeStatus(to: .disconnected)
        default:
            changeStatus(to: .failed)
        }
    }
    
}

// MARK: - Private

// MARK: Helpers
private extension WebSocketToNode {
    
    func tearDown() {
        print("🔌💣 tear down")
        cancellables = Set<AnyCancellable>()
        cleanUpListeners()
        webSocketTask = nil
    }
    
    func cleanUpListeners() {
        self.syncronize { [weak self] in
            self?.listeners.values.forEach {
                $0.send(completion: .finished)
            }
            self?.listeners = [:]
        }
    }
    
    func closeDisregardingListeners(closeCode: URLSessionWebSocketTask.CloseCode, reason: Data? = nil) {
        changeStatus(to: .closing)
        webSocketTask?.cancel(with: closeCode, reason: reason)
    }
    
    func createAndConnectToSocketIfNeeded() {
        guard shouldConnect else { return }
        createAndConnectToSocket()
    }
    
    func createAndConnectToSocket() {
        changeStatus(to: .connecting)
        let webSocketTask: URLSessionWebSocketTask
        defer {
            self.webSocketTask = webSocketTask
            webSocketTask.resume()
            startReceivingMessages()
            schedulePinging(every: .seconds(10))
        }
        let webSocketUrl = node.webSocketsUrl.url
        webSocketTask = urlSession.webSocketTask(with: webSocketUrl)
    }
    
    func startReceivingMessages() {
        webSocketTask?.receive { [unowned self] messageResult in
            guard case .success(let message) = messageResult else {
                // TODO forward errors to listener?
                print("🔌☢️ error receiving \(messageResult)")
                return
            }
            self.syncronize { [weak self] in
                self?.forwardMessageToListeners(message)
            }
            self.startReceivingMessages()
        }
    }
    
    func schedulePinging(every interval: DispatchTimeInterval) {
        RadixSchedulers.timer(
            publishEvery: interval
        ) { [weak self] in
            self?.webSocketTask?.sendPing { error in
                if let error = error {
                    // TODO forward errors to listener?
                    Swift.print("🔌☢️ Error pinging: \(error)")
                }
            }
        }
        .subscribe(on: dispatchQueue)
        .receive(on: RadixSchedulers.backgroundScheduler)
        .ignoreOutput()
        .sink {}
        .store(in: &cancellables)
    }
    
    func forwardMessageToListeners(_ message: URLSessionWebSocketTask.Message) {
        listeners.values.forEach { listener in
            listener.send(message)
        }
    }
    
    func syncronize(_ task: @escaping () -> Void) {
//        RadixSchedulers.backgroundScheduler.async { [weak self] in
//            guard let nonWeakSelf = self else { return }
//            nonWeakSelf.dispatchQueue.sync {
//                task()
//            }
//        }
       
        dispatchQueue.async {
            RadixSchedulers.backgroundScheduler.sync {
                task()
            }
        }
    }
}

// MARK: Status
private extension WebSocketToNode {
    
    func changeStatus(to status: WebSocketStatus) {
        webSocketStatusSubject.send(status)
    }
    
    var shouldConnect: Bool {
        guard !isConnecting else { return false }
        return isDisconnected || isFailed
    }
    
    var isConnecting: Bool { hasStatus(.connecting) }
    var isDisconnected: Bool { hasStatus(.disconnected) }
    
    var isFailed: Bool { hasStatus(.failed) }
    
    var isClosing: Bool { hasStatus(.closing) }
    
    var isConnected: Bool { hasStatus(.connected) }
    
    func hasStatus(_ status: WebSocketStatus) -> Bool {
        webSocketStatusSubject.value == status
    }
}
