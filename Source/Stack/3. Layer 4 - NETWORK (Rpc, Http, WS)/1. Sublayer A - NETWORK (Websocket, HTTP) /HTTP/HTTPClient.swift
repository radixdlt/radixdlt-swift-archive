//
//  HTTPClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol HTTPClient {
    func request<D>(router: Router, decodeAs type: D.Type) -> SingleWanted<D> where D: Decodable
}

public extension HTTPClient {
    func request<D>(router: Router) -> SingleWanted<D> where D: Decodable {
        return request(router: router, decodeAs: D.self)
    }
    
    func request<D>(_ nodeRouter: NodeRouter) -> SingleWanted<D> where D: Decodable {
        return request(router: nodeRouter, decodeAs: D.self)
    }
}
