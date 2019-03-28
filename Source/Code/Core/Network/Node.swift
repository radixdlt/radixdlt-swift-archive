//
//  Node.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

internal extension String {
    static let https = "https://"
    static let http = "http://"
}

/// Unique network node endpoint.
public struct Node: Hashable, Equatable {
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
        var location = location
        
        if location.starts(with: String.https) {
            location.removeFirst(String.https.count)
        }
        if location.starts(with: String.http) {
            location.removeFirst(String.http.count)
        }
        
        let locationAndPort = location.components(separatedBy: ":")
        if locationAndPort.count > 1 {
            // throw away port
            location = locationAndPort[0]
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
            return try Node(location: Enviroment.localhost.baseURL.absoluteString, useSSL: false, port: port)
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
