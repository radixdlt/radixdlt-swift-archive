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
import Combine

public final class DefaultHTTPClient: HTTPClient, Throwing {
    public typealias Error = HTTPClientError

    // Internal for testing only
    public let baseUrl: URL
    private let jsonDecoder: JSONDecoder
    private var cancellables = Set<AnyCancellable>()
    
    private let dataFetcher: DataFetcher
    
    public init(
        baseURL baseURLConvertible: URLConvertible,
        dataFetcher: DataFetcher = .usingURLSession(),
        jsonDecoder: JSONDecoder = .init()
    ) {
        self.baseUrl = baseURLConvertible.url
        self.dataFetcher = dataFetcher
        self.jsonDecoder = jsonDecoder
    }
}

public extension DefaultHTTPClient {
    convenience init(formattedUrl: FormattedURL) {
        self.init(baseURL: formattedUrl.url)
    }
}

// MARK: HTTPClient
public extension DefaultHTTPClient {
    
    func perform(absoluteUrlRequest urlRequest: URLRequest) -> AnyPublisher<Data, HTTPClientError.NetworkingError> {
        return Combine.Deferred { [unowned self] in
            return Future<Data, HTTPClientError.NetworkingError> { promise in
                self.dataFetcher.dataFromRequest(urlRequest)
                .sink(
                    receiveCompletion: { completion in
                        guard case .failure(let error) = completion else { return }
                        promise(.failure(error))
                },
                    receiveValue: { data in
                        promise(.success(data))
                }
                ).store(in: &self.cancellables)
            }
        }.eraseToAnyPublisher()
    }
    
    func performRequest(pathRelativeToBase path: String) -> AnyPublisher<Data, HTTPClientError.NetworkingError> {
        let url = URL(string: path, relativeTo: baseUrl)!
        let urlRequest = URLRequest(url: url)
        return perform(absoluteUrlRequest: urlRequest)
    }
    
    func fetch<D>(urlRequest: URLRequest, decodeAs: D.Type) -> AnyPublisher<D, HTTPClientError> where D: Decodable {
        perform(absoluteUrlRequest: urlRequest)
            .decode(type: D.self, decoder: self.jsonDecoder)
            .mapError { castOrKill(instance: $0, toType: DecodingError.self) }
            .mapError { Error.serializationError(.decodingError($0)) }
            .eraseToAnyPublisher()
    }
    
}
