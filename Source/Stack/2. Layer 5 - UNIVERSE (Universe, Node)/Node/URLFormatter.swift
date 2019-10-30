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

public struct URLFormatter {}

// MARK: - Public
public extension URLFormatter {

    static func format(
        host hostConvertible: HostConvertible,
        `protocol`: CommuncationProtocol,
        appendPath: Bool = true,
        useSSL: Bool = true
    ) throws -> FormattedURL {
        
        if hostConvertible.isLocal && useSSL {
            throw Error.sslIsUnsupportedForLocalhost
        }
        
        var urlComponents = URLComponents()
        urlComponents.host = try validating(isOnlyHost: hostConvertible.domain)
        if appendPath {
            urlComponents.path = `protocol`.path
        }
        urlComponents.port = Int(hostConvertible.port.port)
        urlComponents.scheme = `protocol`.scheme(useSSL: useSSL)

        guard let formattedUrl = urlComponents.url else {
            throw `protocol`.failedToCreateUrl(from: urlComponents.description)
        }
        return FormattedURL(
            url: formattedUrl,
            domain: hostConvertible.domain,
            port: hostConvertible.port,
            isUsingSSL: useSSL
        )
    }
}

public extension URLFormatter {
    static func localhost(`protocol`: CommuncationProtocol) -> FormattedURL {
        do {
            return try URLFormatter.format(host: Host.local(port: 8080), protocol: `protocol`, useSSL: false)
        } catch {
            incorrectImplementation("Failed to create localhost client, error: \(error)")
        }
    }
    
    static var localhostWebsocket: FormattedURL {
        return URLFormatter.localhost(protocol: .webSockets)
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
    enum Error: Swift.Error, Equatable {
        case sslIsUnsupportedForLocalhost
        case nonHostStringPassed(url: String)
        case failedToCreateURLForWebsockets(from: String)
        case failedToCreateURLForHTTP(from: String)
    }
}

public extension URLFormatter {
    enum CommuncationProtocol: Equatable, Hashable {
        case webSockets
        case hypertext
    }
}

public extension URLFormatter.CommuncationProtocol {
    
    static func == (lhs: URLFormatter.CommuncationProtocol, rhs: URLFormatter.CommuncationProtocol) -> Bool {
        switch (lhs, rhs) {
        case (.hypertext, .hypertext): return true
        case (.webSockets, .webSockets): return true
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
        case .webSockets: return secureIfNeeded("ws")
        }
    }
    
    var path: String {
        switch self {
        case .hypertext: return "/api"
        case .webSockets: return "/rpc"
        }
    }
    
    func failedToCreateUrl(from url: URL) -> URLFormatter.Error {
        return failedToCreateUrl(from: url.absoluteString)
    }
    
    func failedToCreateUrl(from urlString: String) -> URLFormatter.Error {
        switch self {
        case .hypertext: return URLFormatter.Error.failedToCreateURLForHTTP(from: urlString)
        case .webSockets: return URLFormatter.Error.failedToCreateURLForWebsockets(from: urlString)
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
