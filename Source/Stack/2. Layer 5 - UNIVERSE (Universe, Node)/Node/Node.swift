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

// swiftlint:disable colon opening_brace

/// Unique network node endpoint.
public struct Node:
    Hashable,
    Equatable,
    Comparable,
    Identifiable,
    CustomDebugStringConvertible
{
    // swiftlint:enable colon opening_brace
    
    public let isUsingSSL: Bool
    public let host: Host
    
    public init(host: Host, isUsingSSL: Bool) throws {
        self.host = host
        self.isUsingSSL = isUsingSSL
        
        // Validate that we CAN format urls
        _ = try URLFormatter.format(host: host, protocol: .webSockets, useSSL: isUsingSSL)
        _ = try URLFormatter.format(host: host, protocol: .hypertext, useSSL: isUsingSSL)
    }
}

public extension Node {
    var webSocketsUrl: FormattedURL { formatUrl(protocol: .webSockets) }
    var hypertextUrl: FormattedURL { formatUrl(protocol: .hypertext) }
}

// MARK: - Identifiable
public extension Node {
    var id: String {
        "\(host.domain):\(host.port)"
    }
}

// MARK: - CustomDebugStringConvertible
public extension Node {
    var debugDescription: String {
        return """
        Node(\(webSocketsUrl.url))
        """
    }
}

public extension Node {
    init(domain: String, port: Port, isUsingSSL: Bool) throws {
        let host = try Host(domain: domain, port: port)
        try self.init(host: host, isUsingSSL: isUsingSSL)
    }
    
    init(ensureDomainNotNil maybeDomain: String?, port: Port, isUsingSSL: Bool) throws {
        guard let domain = maybeDomain else { throw Error.domainCannotBeNil }
        try self.init(domain: domain, port: port, isUsingSSL: isUsingSSL)
    }
    
    enum Error: Swift.Error, Equatable {
        case domainCannotBeNil
    }
}

public extension Node {
    static func < (lhs: Self, rhs: Self) -> Bool {
        compare(lhs, rhs, <)
    }
    
    static func <= (lhs: Self, rhs: Self) -> Bool {
        compare(lhs, rhs, <=)
    }
    
    static func > (lhs: Self, rhs: Self) -> Bool {
        compare(lhs, rhs, >)
    }
    
    static func >= (lhs: Self, rhs: Self) -> Bool {
        compare(lhs, rhs, >=)
    }
    
}

private extension Node {
    static func compare(_ lhs: Self, _ rhs: Self, _ comparison: (Host, Host) -> Bool) -> Bool {
        comparison(lhs.host, rhs.host)
    }
    
    func formatUrl(`protocol`: URLFormatter.CommunicationProtocol) -> FormattedURL {
        do {
            return try URLFormatter.format(host: host, protocol: `protocol`, useSSL: isUsingSSL)
        } catch {
            unexpectedlyMissedToCatch(error: error)
        }
    }
    
}
