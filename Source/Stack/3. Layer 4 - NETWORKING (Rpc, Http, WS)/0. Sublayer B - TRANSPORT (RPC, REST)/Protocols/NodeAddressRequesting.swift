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
import RxSwift

public protocol OriginNodeFinding {
    func findSomeOriginNode(port: Port) -> Single<Node>
}

public extension OriginNodeFinding where Self: HTTPClientOwner {
    func findSomeOriginNode(port: Port = .nodeFinder) -> Single<Node> {
        return httpClient.loadContent(of: "/node-finder")
            .map { try Host(domain: $0, port: port) }
            .map { try Node.init(host: $0, isUsingSSL: true) }
    }
}

public final class OriginNodeFinder: OriginNodeFinding, HTTPClientOwner {
//    private let urlToFinderOfSomeOriginNode: URL
    
    public let httpClient: HTTPClient
    
    private init(formattedUrlToFinderOfSomeOriginNode: FormattedURL) {
        self.httpClient = DefaultHTTPClient(formattedUrl: formattedUrlToFinderOfSomeOriginNode)
    }
}

public extension OriginNodeFinder {
    convenience init(finderOfSomeOriginNode: Host) throws {
        
        let formattedUrlToFinderOfSomeOriginNode = try URLFormatter.format(
            host: finderOfSomeOriginNode,
            protocol: .hypertext,
            appendPath: false,
            useSSL: true
        )
        
        self.init(formattedUrlToFinderOfSomeOriginNode: formattedUrlToFinderOfSomeOriginNode)
    }
    
    convenience init(domain: String, port: Port = .nodeFinder) throws {
        let host = try Host(domain: domain, port: port)
        try self.init(finderOfSomeOriginNode: host)
    }
}

public extension OriginNodeFinder {
    static var betanet: OriginNodeFinder {
        do {
            return try OriginNodeFinder(domain: "https://betanet.radixdlt.com")
        } catch { incorrectImplementation("Should always be able to create an OriginNodeFinder for betanet") }
    }
}
