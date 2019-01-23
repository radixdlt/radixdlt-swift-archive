//
//  Node.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// Unique network node endpoint.
public struct Node {
    public enum Error: Swift.Error {
        case portTooBig
        case portNegative
        case locationEmpty
        case failedToCreateURL(from: String)
    }
    
    public let isUsingSSL: Bool
    public let url: URL
    public let request: URLRequest
    
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
        self.request = URLRequest(url: url)
    }
}
