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
@testable import RadixSDK
import XCTest

extension String: URLConvertible {
    public var url: URL { .init(stringLiteral: self) }
}

final class HTTPClientTests: TestCase {
    func test_data_through() {

        let subject = PassthroughSubject<Data, HTTPClientError.NetworkingError>()
        
        let httpClient: HTTPClient = DefaultHTTPClient(
            baseURL: "http://127.0.0.1",
            dataFetcher: .dataSubject(subject)
        )
        var outputtedValues = [Data]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let cancellable = httpClient.performRequest(pathRelativeToBase: .irrelevant)
        .first()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { outputtedValues.append($0) }
        )
        
        let dataSent = "Hey".toData()
        subject.send(dataSent)
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(outputtedValues.count, 1)
        XCTAssertEqual(outputtedValues[0], dataSent)
        XCTAssertNotNil(cancellable)
    }
    
    func test_url_response_with_status_code_200_through_299() {
        
        func doTest(statusCode: Int) {
            let urlResponseSubject = PassthroughSubject<(data: Data, response: URLResponse), URLError>()
            
            let httpClient: HTTPClient = DefaultHTTPClient(
                baseURL: "http://127.0.0.1",
                dataFetcher: .urlResponse { _ in urlResponseSubject.eraseToAnyPublisher() }
            )
            var outputtedValues = [Data]()
            let expectation = XCTestExpectation(description: self.debugDescription)
            
            let cancellable = httpClient.performRequest(pathRelativeToBase: .irrelevant)
                .first()
                .sink(
                    receiveCompletion: { _ in expectation.fulfill() },
                    receiveValue: { outputtedValues.append($0) }
            )
            
            let data = "Hey".toData()
            let urlResponse = HTTPURLResponse(url: "http://127.0.0.1".url, statusCode: statusCode, httpVersion: "3.0", headerFields: nil)!
            urlResponseSubject.send((data: data, response: urlResponse))
            wait(for: [expectation], timeout: 0.1)
            XCTAssertEqual(outputtedValues.count, 1)
            XCTAssertEqual(outputtedValues[0], data)
            XCTAssertNotNil(cancellable)
        }
        
        for statusCode in 200...299 {
            doTest(statusCode: statusCode)
        }
    }
    
    func test_url_response_with_status_code_not_in_2XY() throws {
        
        let urlResponseSubject = PassthroughSubject<(data: Data, response: URLResponse), URLError>()
        
        let httpClient: HTTPClient = DefaultHTTPClient(
            baseURL: "http://127.0.0.1",
            dataFetcher: .urlResponse { _ in urlResponseSubject.eraseToAnyPublisher() }
        )
        var outputtedValues = [Data]()
        var networkingError: HTTPClientError.NetworkingError?
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let cancellable = httpClient.performRequest(pathRelativeToBase: .irrelevant)
            .first()
            .sink(
                receiveCompletion: { completion in
                    defer {expectation.fulfill() }
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        networkingError = error
                    }
                    
            },
                receiveValue: { outputtedValues.append($0) }
        )
        
        let data = "Hey".toData()
        let urlResponse = HTTPURLResponse(url: "http://127.0.0.1".url, statusCode: 300, httpVersion: "3.0", headerFields: nil)!
        urlResponseSubject.send((data: data, response: urlResponse))
        wait(for: [expectation], timeout: 0.1)

        XCTAssertTrue(outputtedValues.isEmpty)
        
        let error = try XCTUnwrap(networkingError)
        XCTAssertEqual(error, HTTPClientError.NetworkingError.invalidServerStatusCode(300))
        
        XCTAssertNotNil(cancellable)
    }
    
    func test_url_error() throws {
        
        let urlResponseSubject = PassthroughSubject<(data: Data, response: URLResponse), URLError>()
        
        let httpClient: HTTPClient = DefaultHTTPClient(
            baseURL: "http://127.0.0.1",
            dataFetcher: .urlResponse { _ in urlResponseSubject.eraseToAnyPublisher() }
        )
        var outputtedValues = [Data]()
        var networkingError: HTTPClientError.NetworkingError?
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let cancellable = httpClient.performRequest(pathRelativeToBase: .irrelevant)
            .first()
            .sink(
                receiveCompletion: { completion in
                    defer {expectation.fulfill() }
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        networkingError = error
                    }
                    
            },
                receiveValue: { outputtedValues.append($0) }
        )
        let noInternetConnectionError: URLError = .init(.notConnectedToInternet)
        urlResponseSubject.send(completion: .failure(noInternetConnectionError))
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertTrue(outputtedValues.isEmpty)
        
        let error = try XCTUnwrap(networkingError)
        XCTAssertEqual(error, HTTPClientError.NetworkingError.urlError(noInternetConnectionError))
        
        XCTAssertNotNil(cancellable)
    }
    
    func test_url_response_not_httpurlresponse() throws {
        
        let urlResponseSubject = PassthroughSubject<(data: Data, response: URLResponse), URLError>()
        
        let httpClient: HTTPClient = DefaultHTTPClient(
            baseURL: "http://127.0.0.1",
            dataFetcher: .urlResponse { _ in urlResponseSubject.eraseToAnyPublisher() }
        )
        var outputtedValues = [Data]()
        var networkingError: HTTPClientError.NetworkingError?
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let cancellable = httpClient.performRequest(pathRelativeToBase: .irrelevant)
            .first()
            .sink(
                receiveCompletion: { completion in
                    defer {expectation.fulfill() }
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        networkingError = error
                    }
                    
            },
                receiveValue: { outputtedValues.append($0) }
        )
        
        let data = "Hey".toData()
        let urlResponse = URLResponse(url: "http://127.0.0.1".url, mimeType: nil, expectedContentLength: 8, textEncodingName: nil)
        urlResponseSubject.send((data: data, response: urlResponse))
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertTrue(outputtedValues.isEmpty)
        
        let error = try XCTUnwrap(networkingError)
        XCTAssertEqual(error, HTTPClientError.NetworkingError.invalidServerResponse(urlResponse))
        
        XCTAssertNotNil(cancellable)
    }
    
    func test_data_as_model_success() {

        let subject = PassthroughSubject<Data, HTTPClientError.NetworkingError>()

        let httpClient: HTTPClient = DefaultHTTPClient(
            baseURL: "http://127.0.0.1",
            dataFetcher: .dataSubject(subject)
        )
        var outputtedValues = [ResourceIdentifierParticle]()
        let expectation = XCTestExpectation(description: self.debugDescription)

        let cancellable = httpClient.fetch(
            urlRequest: URLRequest(url:  "http://127.0.0.1".url),
            decodeAs: ResourceIdentifierParticle.self
        )
            .first()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { outputtedValues.append($0) }
        )
        
        let rriParticle = ResourceIdentifierParticle(resourceIdentifier: .irrelevant)

        let dataSent = try! JSONEncoder().encode(rriParticle)
        subject.send(dataSent)
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(outputtedValues.count, 1)
        XCTAssertEqual(outputtedValues[0], rriParticle)
        XCTAssertNotNil(cancellable)
    }
    
    func test_data_as_model_bad_json() throws {
        
        let subject = PassthroughSubject<Data, HTTPClientError.NetworkingError>()
        
        let httpClient: HTTPClient = DefaultHTTPClient(
            baseURL: "http://127.0.0.1",
            dataFetcher: .dataSubject(subject)
        )
        var outputtedValues = [ResourceIdentifierParticle]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        var httpClientError: HTTPClientError?
        let cancellable = httpClient.fetch(
            urlRequest: URLRequest(url:  "http://127.0.0.1".url),
            decodeAs: ResourceIdentifierParticle.self
        )
            .first()
            .sink(
                receiveCompletion: { completion in
                    defer {expectation.fulfill() }
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        httpClientError = error
                    } },
                receiveValue: { outputtedValues.append($0) }
        )
        
        
        let dataSent = """
           {
                "destinations": [
                    ":uid:56abab3870585f04d015d55adf600bc7"
                ],
                "nonce": 0,
                "serializer": "radix.particles.rri",
                "version": 100
            }
        """.toData()
        
        subject.send(dataSent)
        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(outputtedValues.isEmpty)
        
        let error = try XCTUnwrap(httpClientError)
        XCTAssertEqual(
            error,
            .serializationError(.decodingError(.keyNotFound(ResourceIdentifierParticle.CodingKeys.resourceIdentifier)))
        )
        
        XCTAssertNotNil(cancellable)
    }
}

extension FormattedURL {
    static let localhostHttp = try! URLFormatter.format(host: Host.local(), protocol: .hypertext, useSSL: false)
    
    static var localhostWebsocket: FormattedURL {
        return URLFormatter.localhostWebsocket
    }
}

extension URLFormatter {
    
    static var localhostWebsocket: FormattedURL {
        return URLFormatter.localhost(protocol: .webSockets)
    }
}

public extension DataFetcher {

    static func dataSubject(_ subject: PassthroughSubject<Data, HTTPClientError.NetworkingError>) -> Self {
        Self { _ in
            subject.eraseToAnyPublisher()
        }
    }
}
