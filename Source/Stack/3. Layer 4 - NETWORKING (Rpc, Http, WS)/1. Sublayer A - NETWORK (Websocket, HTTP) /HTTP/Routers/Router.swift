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
import Alamofire
import RxSwift

public protocol Router: URLRequestConvertible {
    var baseURLString: String? { get }
    var method: Alamofire.HTTPMethod { get }
    var path: URL { get }
    var headers: Alamofire.HTTPHeaders? { get }
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
    
    var method: Alamofire.HTTPMethod {
        return .get
    }
    
    var headers: Alamofire.HTTPHeaders? { return nil }
}

// MARK: URLRequestConvertible Default Conformance
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
