//
//  URL_Extensions.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        guard let url = URL(string: value) else {
            incorrectImplementation("Bad string, failed to create url from: \(value)")
        }
        self = url
    }
}
extension URL {
    func settingBase(url: URL) -> URL {
        let urlString = url.absoluteString + relativePath
        guard let url = URL(string: urlString) else {
            incorrectImplementation("Base url")
        }
        return url
    }
}

extension URLRequest {
    func settingBaseForUrl(base: URL) -> URLRequest {
        var request = self
        guard let url = request.url else {
            incorrectImplementation("no url")
        }
        request.url = url.settingBase(url: base)
        return request
    }
}

extension URL {
    var isLocalhost: Bool {
        let isLocalhost = absoluteString.contains(String.localhost)
        return isLocalhost
    }
    static var localhost: URL {
        return URL(stringLiteral: String.localhost)
    }
}
