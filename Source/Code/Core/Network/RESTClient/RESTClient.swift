//
//  RESTClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol RESTClient {
    func request<D>(router: Router, decodeAs type: D.Type) -> Single<D> where D: Decodable
    func get<D>(from url: URL, decodeAs type: D.Type) -> Single<D> where D: Decodable
}

public extension RESTClient {
    
    func request<D>(router: Router) -> Single<D> where D: Decodable {
        return request(router: router, decodeAs: D.self)
    }
    
    func get<D>(from url: URL) -> Single<D> where D: Decodable {
        return get(from: url, decodeAs: D.self)
    }
}
