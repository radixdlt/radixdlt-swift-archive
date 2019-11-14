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

public protocol Router {
    func asURLRequest() throws -> URLRequest
    var baseURLString: String? { get }
    var method: HTTPMethod { get }
    var path: URL { get }
    var headers: HTTPHeaders? { get }
}

public extension Router where Self: RawRepresentable, Self.RawValue == String {
    var path: URL {
        guard let url = URL(string: rawValue) else {
            incorrectImplementation("Failed to create URL from string: \(rawValue)")
        }
        return url
    }
}

public extension Router {
    
    var baseURLString: String? {
        return "localhost:8080"
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var headers: HTTPHeaders? { return nil }
}

public extension Router {
    func asURLRequest() throws -> URLRequest {
        let url: URL
        if let baseURLString = baseURLString, let baseUrl = URL(string: baseURLString) {
            guard let fullPath = URL(string: path.absoluteString, relativeTo: baseUrl) else {
                incorrectImplementation("Failed to create URL with base: \(baseURLString) and path: \(path.absoluteString)")
            }
            url = fullPath
        } else {
            url = path
        }
        return try URLRequest(url: url, method: method, headers: headers)
    }
}

public enum HTTPMethod: String {
    case get
    case head
    public init(string: String) {
        self.init(rawValue: string)!
    }
}

public struct HTTPHeaders {
    public let dictionary: [String: String]
}

public extension URLRequest {
    /// Creates an instance with the specified `url`, `method`, and `headers`.
    ///
    /// - Parameters:
    ///   - url:     The `URLConvertible` value.
    ///   - method:  The `HTTPMethod`.
    ///   - headers: The `HTTPHeaders`, `nil` by default.
    /// - Throws:    Any error thrown while converting the `URLConvertible` to a `URL`.
    init(url urlConvertible: URLConvertible, method: HTTPMethod, headers: HTTPHeaders? = nil) throws {
        let url = urlConvertible.url
        
        self.init(url: url)
        
        httpMethod = method.rawValue.uppercased()
        allHTTPHeaderFields = headers?.dictionary
    }
}
