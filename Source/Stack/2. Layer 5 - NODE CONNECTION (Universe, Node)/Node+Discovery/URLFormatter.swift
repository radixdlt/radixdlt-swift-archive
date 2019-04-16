//
//  URLFormatter.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct FormattedURL: Hashable, Equatable, ExpressibleByStringLiteral {
    public let url: URL
    public let isUsingSSL: Bool
    public let host: Host
    public let communication: URLFormatter.CommuncationProtocol

    fileprivate init(
            url: URL,
            host: Host,
            communication: URLFormatter.CommuncationProtocol,
            useSSL: Bool
    ) {
        self.host = host
        self.communication = communication
        self.url = url
        self.isUsingSSL = useSSL
    }
}

public extension FormattedURL {
    init(stringLiteral value: String) {
        guard
                let components = URLComponents(string: value),
                let host = components.host,
                let scheme = components.scheme
                else {
            fatalError("Failed to create URLComponents")
        }
        let portInt: Int = components.port ?? 443
        let useSSL = scheme.contains("ps") || scheme.contains("ss")
        let isWebsockets = scheme.contains("ws")
        do {
            let port = try Port(unvalidated: portInt)
            let host = try Host(ipAddress: host, port: port)
            self = try URLFormatter.format(host: host, protocol: isWebsockets ? .websockets(appendPath: false) : .hypertext(appendPath: false), useSSL: useSSL)
        } catch {
            fatalError("Bad string passed: `\(value)`, error: `\(error)`")
        }
    }
}

public extension FormattedURL {
    var isLocal: Bool {
        return host.isLocal
    }
}

public struct URLFormatter {}

// MARK: - Public
public extension URLFormatter {

    static func format(host: Host, `protocol`: CommuncationProtocol, useSSL: Bool = true) throws -> FormattedURL {
        if host.isLocal && useSSL {
            throw Error.sslIsUnsupportedForLocalhost
        }
        var urlComponents = URLComponents()
        urlComponents.host = try validating(isOnlyHost: host.ipAddress)
        if let path = `protocol`.path {
            urlComponents.path = path
        }
        urlComponents.port = Int(host.port.port)
        urlComponents.scheme = `protocol`.scheme(useSSL: useSSL)

        guard let formattedUrl = urlComponents.url else {
            throw `protocol`.failedToCreateUrl(from: urlComponents.description)
        }
        return FormattedURL(url: formattedUrl, host: host, communication: `protocol`, useSSL: useSSL)
    }

    static func format(url: FormattedURL, `protocol`: CommuncationProtocol, useSSL: Bool = true) throws -> FormattedURL {
        return try format(host: url.host, protocol: `protocol`, useSSL: useSSL)
    }
}

// MARK: - Convenience
public extension URLFormatter {

//    static func format(url: URL, port: Port? = nil, `protocol`: CommuncationProtocol, useSSL: Bool = true) throws -> URL {
//
//        let host: String
//        if let hostFromUrlString = try? validating(isOnlyHost: url.absoluteString) {
//            host = hostFromUrlString
//        } else if let hostFromUrl = url.host {
//            host = hostFromUrl
//        } else if case let absolute = url.absoluteString, absolute == .localhost {
//            host = .localhost
//        } else {
//            throw `protocol`.failedToCreateUrl(from: url.absoluteString)
//        }
//        return try format(host: host, port: port, protocol: `protocol`, useSSL: useSSL)
//    }

    /// Swift.URL ignores `:<port>` part of strings, thus re
    static func format(ipAddress: String, port: Port, `protocol`: CommuncationProtocol, useSSL: Bool = true) throws -> FormattedURL {
        let host = try Host(ipAddress: ipAddress, port: port)
        return try format(host: host, protocol: `protocol`, useSSL: useSSL)
    }
}

public extension URLFormatter {
    static var localhost: FormattedURL {
        do {
            return try URLFormatter.format(host: .local(port: 8080), protocol: .hypertext(appendPath: true), useSSL: false)
        } catch {
            incorrectImplementation("Failed to create localhost client, error: \(error)")
        }
    }
}

// MARK: - Private
private extension URLFormatter {
    
    static func validating(isOnlyHost urlString: String) throws -> String {
        guard onlyHost(string: urlString) else {
            throw Error.nonHostStringPassed(url: urlString)
        }
        return urlString
    }
    
    /// An IP address consists of `{ 0...255 }` x 4, thus all fitting inside `UInt8`
    /// If `string` passed contains slashes, it is not ONLY a host, but also contains path
    /// components, thus failign this check.
    static func onlyHost(string: String) -> Bool {
        if string == .localhost { return true }
        if string.contains("/") { return false }
        let components = string.components(separatedBy: ".")

        let integers = components.compactMap({ Int($0) })
        let uint8s = components.compactMap({ UInt8($0) })
        
        if integers.count == 4 {
            // e.g. 32.64.128.42
            return integers.count == uint8s.count
        } else {
            return true
        }
    }
}

// MARK: - Error
public extension URLFormatter {
    enum Error: Swift.Error {
        case sslIsUnsupportedForLocalhost
        case nonHostStringPassed(url: String)
        case failedToCreateURLForWebsockets(from: String)
        case failedToCreateURLForHTTP(from: String)
    }
}

public extension URLFormatter {
    enum CommuncationProtocol: Equatable, Hashable {
        case websockets(appendPath: Bool)
        case hypertext(appendPath: Bool)
    }
}

public extension URLFormatter.CommuncationProtocol {
    
    static func == (lhs: URLFormatter.CommuncationProtocol, rhs: URLFormatter.CommuncationProtocol) -> Bool {
        switch (lhs, rhs) {
        case (.hypertext, .hypertext): return true
        case (.websockets, .websockets): return true
        default: return false
        }
    }
}

private extension URLFormatter.CommuncationProtocol {
    
    func scheme(useSSL: Bool = true) -> String {
        func secureIfNeeded(_ string: String) -> String {
            return string.appending("s", if: useSSL)
        }
        
        switch self {
        case .hypertext: return secureIfNeeded("http")
        case .websockets: return secureIfNeeded("ws")
        }
    }
    
    var path: String? {
        switch self {
        case .hypertext(let appendPath):
            guard appendPath else { return nil }
            return "/api"
        case .websockets(let appendPath):
            guard appendPath else { return nil }
            return "/rpc"
        }
    }
    
    func failedToCreateUrl(from url: URL) -> URLFormatter.Error {
        return failedToCreateUrl(from: url.absoluteString)
    }
    
    func failedToCreateUrl(from urlString: String) -> URLFormatter.Error {
        switch self {
        case .hypertext: return URLFormatter.Error.failedToCreateURLForHTTP(from: urlString)
        case .websockets: return URLFormatter.Error.failedToCreateURLForWebsockets(from: urlString)
        }
    }
    
}

private extension String {
    func appending(_ string: String, `if` conditionalAppend: @autoclosure () -> Bool) -> String {
        guard conditionalAppend() else {
            return self
        }
        return self.appending(string)
    }
}

private extension URL {
    func ifNotPresentAppendingPathComponent(_ pathComponent: String) -> URL {
        var copy = self
        copy.ifNotPresentAppendPathComponent(pathComponent)
        return copy
    }
    
    mutating func ifNotPresentAppendPathComponent(_ pathComponent: String) {
        guard self.lastPathComponent != pathComponent else { return }
        appendPathComponent(pathComponent)
    }
}

extension String {
    static let localhost = "localhost"
}
