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

public protocol URLConvertible {
    var url: URL { get }
}
extension URL: URLConvertible {
    public var url: URL { return self }
}

public enum HTTPClientError: Swift.Error, Equatable {
    indirect case networkingError(NetworkingError)
    indirect case serializationError(SerializationError)
}

public extension HTTPClientError {
    enum NetworkingError: Swift.Error, Equatable {
        case urlError(URLError)
        case invalidServerResponse(URLResponse)
        case invalidServerStatusCode(Int)
        
    }
    
    enum SerializationError: Swift.Error, Equatable {
        case decodingError(DecodingError)
        case inputDataNilOrZeroLength
        case stringSerializationFailed(encoding: String.Encoding)
    }
}

public struct DataFetcher {
    
    public typealias DataFromRequest = (URLRequest) -> AnyPublisher<Data, HTTPClientError.NetworkingError>
    let dataFromRequest: DataFromRequest
}

public extension DataFetcher {
    
    static func urlResponse(_ dataAndUrlResponsePublisher: @escaping (URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError>) -> Self {
        Self { request in
            dataAndUrlResponsePublisher(request)
                .mapError { HTTPClientError.NetworkingError.urlError($0) }
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw HTTPClientError.NetworkingError.invalidServerResponse(response)
                    }
                    guard case 200...299 = httpResponse.statusCode else {
                        throw HTTPClientError.NetworkingError.invalidServerStatusCode(httpResponse.statusCode)
                    }
                    return data
            }
            .mapError { castOrKill(instance: $0, toType: HTTPClientError.NetworkingError.self) }
            .eraseToAnyPublisher()
            
        }
    }
    
    static func usingURLSession(_ urlSession: URLSession = .shared) -> Self {
        return Self.urlResponse { urlSession.dataTaskPublisher(for: $0).eraseToAnyPublisher() }
    }
    
//    static func usingURLSession(_ urlSession: URLSession = .shared) -> Self {
//        Self { request in
//             urlSession.dataTaskPublisher(for: request)
//                .mapError { HTTPClientError.NetworkingError.urlError($0) }
//                .tryMap { data, response -> Data in
//                    guard let httpResponse = response as? HTTPURLResponse else {
//                        throw HTTPClientError.NetworkingError.invalidServerResponse(response)
//                    }
//                    guard httpResponse.statusCode == 200 else {
//                        throw HTTPClientError.NetworkingError.invalidServerStatusCode(httpResponse.statusCode)
//                    }
//                    return data
//             }
//             .mapError { castOrKill(instance: $0, toType: HTTPClientError.NetworkingError.self) }
//                .eraseToAnyPublisher()
//
//        }
//    }
}

public final class DefaultHTTPClient: HTTPClient, Throwing {
    public typealias Error = HTTPClientError
    
//    private let urlSession: URLSession

    // Internal for testing only
    public let baseUrl: URL
    private let jsonDecoder: JSONDecoder
    private var cancellables = Set<AnyCancellable>()
    
//    public typealias ResponseFromRequest = (URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
//    private let responseFromRequest: ResponseFromRequest
    private let dataFetcher: DataFetcher
    
    public init(
        baseURL baseURLConvertible: URLConvertible,
//        urlSession: URLSession = .shared,
        dataFetcher: DataFetcher = .usingURLSession(),
        jsonDecoder: JSONDecoder = .init()
    ) {
        self.baseUrl = baseURLConvertible.url
//        self.urlSession = urlSession
//        self.responseFromRequest = responseFromRequest
        self.dataFetcher = dataFetcher
        self.jsonDecoder = jsonDecoder
    }
    
}

public extension DefaultHTTPClient {
    convenience init(formattedUrl: FormattedURL) {
        self.init(baseURL: formattedUrl.url)
    }
}

// MARK: - HTTPClient
public extension DefaultHTTPClient {
 
    func loadContent(of page: String) -> AnyPublisher<String, Error> {
//        let url = URL(string: page)!
//        let urlRequest = URLRequest(url: url)
//
//        return Combine.Deferred { [unowned urlSession] in
//            return Future<String, Error> { promise in
//                urlSession.responseStringPublisher(for: urlRequest)
//                    .sink(
//                        receiveCompletion: { completion in
//                            guard case .failure(let error) = completion else { return }
//                            promise(.failure(error))
//                    },
//                        receiveValue: { string in
//                            promise(.success(string))
//                    }
//                ).store(in: &self.cancellables)
//            }
//
//        }.eraseToAnyPublisher()
        combineMigrationInProgress()
    }
}

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

public extension URLSession {
    func responseStringPublisher(for urlRequest: URLRequest, encoding: String.Encoding? = nil) -> AnyPublisher<String, HTTPClientError> {
        dataTaskPublisher(for: urlRequest)
            .mapError { HTTPClientError.networkingError(.urlError($0)) }
            .tryMap { data, response throws -> String in
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw HTTPClientError.networkingError(.invalidServerResponse(response))
                }
                
                guard !data.isEmpty else {
                    guard emptyResponseAllowed(forRequest: urlRequest, response: httpResponse) else {
                        throw HTTPClientError.serializationError(.inputDataNilOrZeroLength)
                    }
                    return ""
                }
                
                var convertedEncoding = encoding
                
                if let encodingName = httpResponse.textEncodingName as CFString?, convertedEncoding == nil {
                    let ianaCharSet = CFStringConvertIANACharSetNameToEncoding(encodingName)
                    let nsStringEncoding = CFStringConvertEncodingToNSStringEncoding(ianaCharSet)
                    convertedEncoding = String.Encoding(rawValue: nsStringEncoding)
                }
                
                let actualEncoding = convertedEncoding ?? .isoLatin1
                
                guard let string = String(data: data, encoding: actualEncoding) else {
                    throw HTTPClientError.serializationError(.stringSerializationFailed(encoding: actualEncoding))
                }
                
                return string
            }
            .mapError { castOrKill(instance: $0, toType: HTTPClientError.self) }
            .eraseToAnyPublisher()
    }
}

private func requestAllowsEmptyResponseData(
    _ request: URLRequest?,
    emptyRequestMethods: Set<HTTPMethod> = [.head]
) -> Bool? {
    return request.flatMap { $0.httpMethod }
        .flatMap(HTTPMethod.init)
        .map { emptyRequestMethods.contains($0) }
}

private func emptyResponseAllowed(forRequest request: URLRequest?, response: HTTPURLResponse?) -> Bool {
    return (requestAllowsEmptyResponseData(request) == true) || (responseAllowsEmptyResponseData(response) == true)
}

/// - Parameter emptyResponseCodes: HTTP response codes for which empty response bodies are considered appropriate. `[204, 205]` by default.
private func responseAllowsEmptyResponseData(
    _ response: HTTPURLResponse?,
    emptyResponseCodes: Set<Int> = [204, 205]
) -> Bool? {
    return response.flatMap { $0.statusCode }
        .map { emptyResponseCodes.contains($0) }
}
