//
//  Router.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

public protocol Router: URLRequestConvertible {
    var baseURLString: String? { get }
    var method: Alamofire.HTTPMethod { get }
    var path: URL { get }
    var headers: Alamofire.HTTPHeaders? { get }
}

public extension Router where Self: RawRepresentable, Self.RawValue == String {
    var path: URL {
        guard let url = URL(string: rawValue) else {
            incorrectImplementation("Failed to create URL from string: \(rawValue)")
        }
        return url
    }
}

public extension Router {
    
    var baseURLString: String? {
        return "localhost:8080"
    }
    
    var method: Alamofire.HTTPMethod {
        return .get
    }
    
    var headers: Alamofire.HTTPHeaders? { return nil }
}

// MARK: URLRequestConvertible Default Conformance
public extension Router {
    func asURLRequest() throws -> URLRequest {
        let url: URL
        if let baseURLString = baseURLString, let baseUrl = URL(string: baseURLString) {
            guard let fullPath = URL(string: path.absoluteString, relativeTo: baseUrl) else {
                incorrectImplementation("Failed to create URL with base: \(baseURLString) and path: \(path.absoluteString)")
            }
            url = fullPath
        } else {
            url = path
        }
        return try URLRequest(url: url, method: method, headers: headers)
    }
}
