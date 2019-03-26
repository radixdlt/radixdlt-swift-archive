//
//  NodeFinder.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

extension String {
    static var localhostUrl: String {
        return "http://127.0.0.1:8080"
    }
}

extension URL {
    static var localhost: URL {
        guard let localhost = URL(string: .localhostUrl) else {
            incorrectImplementation("failed to create localhost url, are your local node running at `\(String.localhostUrl)`?")
        }
        return localhost
    }
    
    var isLocalhost: Bool {
        return absoluteString == .localhostUrl
    }
}

public final class NodeFinder {
    private let url: URL
    private let port: Int
    public init(baseURL url: URL, port: Int) {
        self.url = url
        self.port = port
    }
}

public extension NodeFinder {
    // swiftlint:disable:next function_body_length
    func getSeed() -> Observable<Node> {
        let port = self.port
        let url = self.url
        return Single<String>.create { single in
            let dataTask = Alamofire.Session.default.request(url).responseString { response in
                switch response.result {
                case .failure(let error): single(.error(error))
                case .success(let string): single(.success(string))
                }
            }
            return Disposables.create { dataTask.cancel() }
            }.map {
                let urlString = $0
                if url.isLocalhost && urlString == .returnedByWebpageForLocalhost {
                    return Node.localhost(port: port)
                } else {
                    return Node.init(urlString: urlString, port: port)
                }
        }.asObservable()
    }
}

// For testing
private extension String {
    static var returnedByWebpageForLocalhost: String {
        return "No matching path found for GET /"
    }
}

private extension Node {
    init(urlString: String, port: Int) {
        do {
            try self.init(location: urlString, useSSL: true, port: port)
        } catch {
            incorrectImplementation("Error: \(error)")
        }
    }
}
