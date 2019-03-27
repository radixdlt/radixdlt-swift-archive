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

public final class NodeFinder: NodeDiscovery {
    private let url: URL
    private let port: Int
    public init(baseURL url: URL, port: Int) {
        self.url = url
        self.port = port
    }
}

public extension NodeFinder {
    // swiftlint:disable:next function_body_length
    func loadNodes() -> Observable<[Node]> {
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
            }.asObservable().map {
                [$0]
        }
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
