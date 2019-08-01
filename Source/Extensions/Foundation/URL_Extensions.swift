/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import Foundation

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        guard let url = URL(string: value) else {
            incorrectImplementation("Bad string, failed to create url from: \(value)")
        }
        self = url
    }
}
extension URL {
    func settingBase(url: URL) -> URL {
        let urlString = url.absoluteString + relativePath
        guard let url = URL(string: urlString) else {
            incorrectImplementation("Base url")
        }
        return url
    }
}

extension URLRequest {
    func settingBaseForUrl(base: URL) -> URLRequest {
        var request = self
        guard let url = request.url else {
            incorrectImplementation("no url")
        }
        request.url = url.settingBase(url: base)
        return request
    }
}

extension URL {
    var isLocalhost: Bool {
        let isLocalhost = absoluteString.contains(String.localhost)
        return isLocalhost
    }
    static var localhost: URL {
        return URL(stringLiteral: String.localhost)
    }
}
