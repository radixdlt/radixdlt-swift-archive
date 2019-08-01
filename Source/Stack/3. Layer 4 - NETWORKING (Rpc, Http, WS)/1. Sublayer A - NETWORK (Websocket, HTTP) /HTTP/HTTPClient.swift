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
    func request<D>(router: Router, decodeAs type: D.Type) -> Single<D> where D: Decodable
    
    func loadContent(of page: String) -> Single<String>
}

public extension HTTPClient {
    func request<D>(router: Router) -> Single<D> where D: Decodable {
        return request(router: router, decodeAs: D.self)
    }
    
    func request<D>(_ nodeRouter: NodeRouter) -> Single<D> where D: Decodable {
        return request(router: nodeRouter, decodeAs: D.self)
    }
}
