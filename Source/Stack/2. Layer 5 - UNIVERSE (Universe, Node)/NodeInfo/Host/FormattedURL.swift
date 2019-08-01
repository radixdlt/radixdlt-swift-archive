//
//  FormattedURL.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

public struct FormattedURL:
    HostConvertible,
    URLConvertible,
    Hashable
{
    // swiftlint:enable colon opening_brace

    public let url: URL
    public let domain: String
    public let port: Port
    public let isUsingSSL: Bool
    
    public init(url: URL, domain: String, port: Port, isUsingSSL: Bool) {
        self.url = url
        self.domain = domain
        self.port = port
        self.isUsingSSL = isUsingSSL
    }
}

public extension FormattedURL {
    static var localhostWebsocket: FormattedURL {
        return URLFormatter.localhostWebsocket
    }
}
