//
//  RESTClientsRetainer.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-27.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// All RESTClients are created and managed here
public final class RESTClientsRetainer {
    public static let shared = RESTClientsRetainer()
    
    private var clientsForNodeUrl: [FormattedURL: DefaultRESTClient] = [:]
    
    private init() {}
}

// MARK: - Public Class Methods
public extension RESTClientsRetainer {
    
    class func restClient(urlToNode: FormattedURL) -> DefaultRESTClient {
        return shared.restClient(urlToNode: urlToNode)
    }
    
//    class func restClient(node: Node) -> RESTClient {
//        return restClient(urlToNode: node.httpUrl)
//    }
}

// MARK: - Private Instance Methods
private extension RESTClientsRetainer {
    
    func restClient(urlToNode: FormattedURL) -> DefaultRESTClient {
        return clientsForNodeUrl.valueForKey(key: urlToNode) {
            DefaultRESTClient(formattedUrl: urlToNode)
        }
    }

}
