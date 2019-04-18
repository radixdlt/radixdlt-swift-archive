//
//  URLFormatter.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct URLFormatter {}

// MARK: - Public
public extension URLFormatter {

    static func format(
        url urlConvertible: URLConvertible,
        `protocol`: CommuncationProtocol,
        appendPath: Bool = true,
        useSSL: Bool = true
    ) throws -> FormattedURL {
        
        if urlConvertible.isLocal && useSSL {
            throw Error.sslIsUnsupportedForLocalhost
        }
        
        var urlComponents = URLComponents()
        urlComponents.host = try validating(isOnlyHost: urlConvertible.host)
        if appendPath {
            urlComponents.path = `protocol`.path
        }
        urlComponents.port = Int(urlConvertible.port.port)
        urlComponents.scheme = `protocol`.scheme(useSSL: useSSL)

        guard let formattedUrl = urlComponents.url else {
            throw `protocol`.failedToCreateUrl(from: urlComponents.description)
        }
        return FormattedURL(url: formattedUrl, host: urlConvertible.host, port: urlConvertible.port, isUsingSSL: useSSL)
    }
}

public extension URLFormatter {
    static var localhost: FormattedURL {
        do {
            return try URLFormatter.format(url: Host.local(port: 8080), protocol: .hypertext, useSSL: false)
        } catch {
            incorrectImplementation("Failed to create localhost client, error: \(error)")
        }
    }
}

// MARK: - Private
extension URLFormatter {
    
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
        case websockets
        case hypertext
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
    
    var path: String {
        switch self {
        case .hypertext: return "/api"
        case .websockets: return "/rpc"
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
