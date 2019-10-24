//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation
import Alamofire
import Combine

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
    func request<D>(router: Router, decodeAs type: D.Type) -> CombineSingle<D> where D: Decodable {
        return request { alamofireSession in
            alamofireSession.request(router)
        }
    }
    
    func loadContent(of page: String) -> CombineSingle<String> {
//        return CombineObservable.deferred { [unowned alamofireSession] in
//            return CombineObservable<String>.create { observer in
//                let dataTask = alamofireSession.request(page).responseString { response in
//                    switch response.result {
//                    case .failure(let error):
//                        log.error(error)
//                        observer.onError(error)
//                    case .success(let string):
//                        log.debug(string)
//                        observer.send(string)
//                        observer.onCompleted()
//                    }
//                }
//                return CombineDisposables.create { dataTask.cancel() }
//            }
//        }
//        .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
//        .subscribeOn(MainScheduler.instance)
//        .asSingle()
        combineMigrationInProgress()
    }
    
    enum Error: Swift.Error {
        case underlyingUrlSessionNil
    }
}

// MARK: - Private
private extension DefaultHTTPClient {
    func request<D>(_ makeRequest: @escaping (Alamofire.Session) -> Alamofire.DataRequest) -> CombineSingle<D> where D: Decodable {
//        return CombineObservable<D>.deferred { [weak alamofireSession] in
//            return CombineObservable.create { observer in
//                guard let alamofireSession = alamofireSession else {
//                    log.error("alamofireSession is nil")
//                    observer.onError(Error.underlyingUrlSessionNil)
//                    return CombineDisposables.create()
//                }
//                let dataRequest: Alamofire.DataRequest = makeRequest(alamofireSession)
//                    .validate()
//                    .responseString { $0.responseString.printIfPresent() }
//                    .responseDecodable { (response: DataResponse<D>) -> Void in
//                        switch response.result {
//                        case .failure(let error):
//                            log.error(error)
//                            observer.onError(error)
//                        case .success(let model):
//                            log.verbose(model)
//                            observer.send(model)
//                            observer.onCompleted()
//                        }
//                }
//                return CombineDisposables.create { dataRequest.cancel() }
//            }
//        }
//        .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
//        .subscribeOn(MainScheduler.instance)
//        .asSingle()
        combineMigrationInProgress()
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
