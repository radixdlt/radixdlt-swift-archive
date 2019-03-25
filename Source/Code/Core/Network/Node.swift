//
//  Node.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct FoundNode: Decodable {
    public struct Host: Decodable {
        // swiftlint:disable:next identifier_name
        public let ip: String
        public let port: Int
    }
    public let host: Host
}

/// Unique network node endpoint.
public struct Node: Hashable {
    public enum Error: Swift.Error {
        case portTooBig
        case portNegative
        case locationEmpty
        case failedToCreateURL(from: String)
    }
    
    public let isUsingSSL: Bool
    public let url: URL
    
    // swiftlint:disable:next function_body_length
    public init(location: String, useSSL: Bool, port: Int) throws {
        guard port >= 0 else {
            throw Error.portNegative
        }
        guard port <= 65535 else {
            throw Error.portTooBig
        }
        guard !location.isEmpty else {
            throw Error.locationEmpty
        }
        
        let base = useSSL ? "wss://" : "ws://"
        let urlString =  "\(base)\(location):\(port)/rpc"
        guard let url = URL(string: urlString) else {
            throw Error.failedToCreateURL(from: urlString)
        }
        self.url = url
        self.isUsingSSL = useSSL
    }
}

public extension Node {
    
    static func localhost(port: Int) -> Node {
        do {
            return try Node(location: "http://127.0.0.1", useSSL: false, port: port)
        } catch {
            incorrectImplementation("Error: \(error)")
        }
    }
    
    init(found: FoundNode, useSSL: Bool = true, port: Int? = nil) {
        do {
            try self.init(location: found.host.ip, useSSL: useSSL, port: port ?? found.host.port)
        } catch {
            incorrectImplementation("Error: \(error)")
        }
    }
}

public extension Node {
    var request: URLRequest {
        return URLRequest(url: url)
    }
}
