//
//  FormattedURL.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct FormattedURL: Hashable, Equatable, URLConvertible {
    public let url: URL
    public let host: String
    public let port: Port
    public let isUsingSSL: Bool
    public init(url: URL, host: String, port: Port, isUsingSSL: Bool) {
        self.url = url
        self.host = host
        self.port = port
        self.isUsingSSL = isUsingSSL
    }
}
