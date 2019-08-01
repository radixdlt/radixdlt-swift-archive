//
//  DefaultHTTPClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

public protocol URLConvertible {
    var url: URL { get }
}
extension URL: URLConvertible {
    public var url: URL { return self }
}

public final class DefaultHTTPClient: HTTPClient, RequestInterceptor {
    
    private let alamofireSession: Alamofire.Session

    // Internal for testing only
    internal let baseUrl: URL
    
    public init(
        baseURL baseURLConvertible: URLConvertible,
        makeRequestInterceptor: ((URLConvertible) -> Alamofire.RequestInterceptor) = HTTPRequestInterceptor.init
    ) {
        let baseURL = baseURLConvertible.url
        self.baseUrl = baseURL
        let configuration = URLSessionConfiguration.default
        let interceptor = makeRequestInterceptor(baseURL.url)
        
        var evaluators: [String: ServerTrustEvaluating] = [
            String.localhost: DisabledEvaluator()
        ]
        
        if let host = baseURL.host {
            evaluators[host] = DisabledEvaluator()
        }
       
        let trustManager = ServerTrustManager(evaluators: evaluators)
        
        alamofireSession = Alamofire.Session(
            configuration: configuration,
            interceptor: interceptor,
            serverTrustManager: trustManager
        )
    }
    
    deinit {
        log.error("💣")
    }
}

public extension DefaultHTTPClient {
    convenience init(formattedUrl: FormattedURL) {
        self.init(baseURL: formattedUrl.url)
    }
}

// MARK: - HTTPClient
public extension DefaultHTTPClient {
    func request<D>(router: Router, decodeAs type: D.Type) -> Single<D> where D: Decodable {
        return request { alamofireSession in
            alamofireSession.request(router)
        }
    }
    
    func loadContent(of page: String) -> Single<String> {
        return Observable.deferred { [unowned alamofireSession] in
            return Observable<String>.create { observer in
                let dataTask = alamofireSession.request(page).responseString { response in
                    switch response.result {
                    case .failure(let error):
                        log.error(error)
                        observer.onError(error)
                    case .success(let string):
                        log.debug(string)
                        observer.onNext(string)
                        observer.onCompleted()
                    }
                }
                return Disposables.create { dataTask.cancel() }
            }
        }
        .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .subscribeOn(MainScheduler.instance)
        .asSingle()
    }
    
    enum Error: Swift.Error {
        case underlyingUrlSessionNil
    }
}

// MARK: - Private
private extension DefaultHTTPClient {
    func request<D>(_ makeRequest: @escaping (Alamofire.Session) -> Alamofire.DataRequest) -> Single<D> where D: Decodable {
        return Observable<D>.deferred { [weak alamofireSession] in
            return Observable.create { observer in
                guard let alamofireSession = alamofireSession else {
                    log.error("alamofireSession is nil")
                    observer.onError(Error.underlyingUrlSessionNil)
                    return Disposables.create()
                }
                let dataRequest: Alamofire.DataRequest = makeRequest(alamofireSession)
                    .validate()
                    .responseString { $0.responseString.printIfPresent() }
                    .responseDecodable { (response: DataResponse<D>) -> Void in
                        switch response.result {
                        case .failure(let error):
                            log.error(error)
                            observer.onError(error)
                        case .success(let model):
                            log.verbose(model)
                            observer.onNext(model)
                            observer.onCompleted()
                        }
                }
                return Disposables.create { dataRequest.cancel() }
            }
        }
        .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .subscribeOn(MainScheduler.instance)
        .asSingle()
    }
}

private extension Alamofire.DataResponse where Value == String {
    var responseString: String? {
        switch result {
        case .failure: return nil
        case .success(let stringValue): return stringValue
        }
    }
}
