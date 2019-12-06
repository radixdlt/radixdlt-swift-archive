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

public final class HTTPPageLoader {
    
    private let urlSession: URLSession
    private var cancellables = Set<AnyCancellable>()
    
    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
}

public extension HTTPPageLoader {
    func loadContent(of page: String) -> AnyPublisher<String, Error> {
        let url = URL(string: page)!
        let urlRequest = URLRequest(url: url)
        
        return Combine.Deferred {
            return Future<String, Error> { [weak self] promise in
                guard let self = self else {
                    promise(.failure(HTTPError.networkingError(.clientWasDeinitialized)))
                    return
                }
                self.urlSession.responseStringPublisher(for: urlRequest)
                    .sink(
                        receiveCompletion: { completion in
                            guard case .failure(let error) = completion else { return }
                            promise(.failure(error))
                    },
                        receiveValue: { string in
                            promise(.success(string))
                    }
                ).store(in: &self.cancellables)
            }
            
        }.eraseToAnyPublisher()
    }
}

public extension URLSession {
    func responseStringPublisher(for urlRequest: URLRequest, encoding: String.Encoding? = nil) -> AnyPublisher<String, HTTPError> {
        dataTaskPublisher(for: urlRequest)
            .mapError { HTTPError.networkingError(.urlError($0)) }
            .tryMap { data, response throws -> String in
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw HTTPError.networkingError(.invalidServerResponse(response))
                }
                
                guard !data.isEmpty else {
                    guard emptyResponseAllowed(forRequest: urlRequest, response: httpResponse) else {
                        throw HTTPError.serializationError(.inputDataNilOrZeroLength)
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
                    throw HTTPError.serializationError(.stringSerializationFailed(encoding: actualEncoding))
                }
                
                return string
        }
        .mapError { castOrKill(instance: $0, toType: HTTPError.self) }
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

