//
//  HTTPRequestInterceptor.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import Alamofire

public final class HTTPRequestInterceptor: RequestInterceptor {
    private let baseURL: URL
    public init(baseURL: RadixSDK.URLConvertible) {
        self.baseURL = baseURL.url
    }
}

// MARK: - RequestInterceptor
public extension HTTPRequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Alamofire.Session, completion: @escaping (Alamofire.Result<URLRequest>) -> Void) {
        var urlRequest = urlRequest
        if urlRequest.url?.baseURL != baseURL {
            urlRequest = urlRequest.settingBaseForUrl(base: baseURL)
        }
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Alamofire.Request, for session: Alamofire.Session, dueTo error: Error, completion: @escaping (Alamofire.RetryResult) -> Void) {
        completion(.doNotRetry)
    }
}
