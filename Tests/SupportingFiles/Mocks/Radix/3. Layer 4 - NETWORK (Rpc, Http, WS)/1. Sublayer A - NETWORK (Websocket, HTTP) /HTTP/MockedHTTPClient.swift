//
//  MockedHTTPClient.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import RxSwift

struct MockedHTTPClient: HTTPClient {
    private let httpResponse: Observable<String>
    init(httpResponse: Observable<String>) {
        self.httpResponse = httpResponse
    }
    
    func request<D>(router: Router, decodeAs type: D.Type) -> SingleWanted<D> where D: Decodable {
        return httpResponse.map {
            try JSONDecoder().decode(D.self, from: $0.toData())
        }
    }
    
    func loadContent(of page: String) -> SingleWanted<String> {
        abstract()
    }
}
