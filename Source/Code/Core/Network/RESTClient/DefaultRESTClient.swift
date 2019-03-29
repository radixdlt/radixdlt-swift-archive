//
//  DefaultRESTClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

public final class DefaultRESTClient: RESTClient, RequestInterceptor {
    
    private let alamofireSession: Alamofire.Session
    
    public init(baseURL: URL? = nil) {
        let configuration = URLSessionConfiguration.default
        let interceptor = RESTRequestInterceptor(baseURL: baseURL)
        alamofireSession = Alamofire.Session(configuration: configuration, interceptor: interceptor)
    }
}

public extension DefaultRESTClient {
    
    func request<D>(router: Router, decodeAs type: D.Type) -> Single<D> where D: Decodable {
        return request { [unowned alamofireSession] in
            alamofireSession.request(router)
        }
    }
    
    func get<D>(from url: URL, decodeAs type: D.Type) -> Single<D> where D: Decodable {
        return request { [unowned alamofireSession] in
            alamofireSession.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil, interceptor: nil)
        }
    }
    
    func request<D>(_ makeRequest: @escaping () -> Alamofire.DataRequest) -> Single<D> where D: Decodable {
        return Single<D>.create { single in
            let dataRequest: Alamofire.DataRequest = makeRequest()
                .validate()
                .responseDecodable { (response: DataResponse<D>) -> Void in
                    switch response.result {
                    case .failure(let error):
                        log.error(error)
                        single(.error(error))
                    case .success(let model):
                        single(.success(model))
                    }
            }
            return Disposables.create { dataRequest.cancel() }
        }
    }
}
