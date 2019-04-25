//
//  PrefixedJSONDecoder.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol PrefixedJsonDecodableByProxy: PrefixedJsonDecodable {
    associatedtype Proxy: PrefixedJsonDecodable
    init(proxy: Proxy) throws
}

public extension PrefixedJsonDecodableByProxy {
    static var jsonPrefix: JSONPrefix {
        return Proxy.jsonPrefix
    }
    init(prefixedString: PrefixedStringWithValue) throws {
        let proxy = try Proxy(prefixedString: prefixedString)
        try self.init(proxy: proxy)
    }
}

public protocol PrefixedJsonEncodableByProxy: PrefixedJsonEncodable {
    associatedtype Proxy: PrefixedJsonEncodable
    var proxy: Proxy { get }
}

public extension PrefixedJsonEncodableByProxy {
    var prefixedString: PrefixedStringWithValue {
        return proxy.prefixedString
    }
}
public typealias PrefixedJsonCodableByProxy = PrefixedJsonDecodableByProxy & PrefixedJsonEncodableByProxy
