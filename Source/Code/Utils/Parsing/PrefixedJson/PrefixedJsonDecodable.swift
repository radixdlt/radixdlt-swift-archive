//
//  PrefixedJsonDecodable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol PrefixedJsonDecodable: CustomStringConvertible, Decodable {
    static var tag: JSONPrefix { get }
    associatedtype From: StringInitializable
    init(from: From) throws
}

extension String: PrefixedJsonDecodable {
    public static var tag: JSONPrefix { return .string }
    public init(from: String) throws {
        self = from
    }
}

public protocol PrefixedJsonEncodable: Encodable {
//    static var tag: JSONPrefix { get }
//    var stringToDecode: String { get }
}

public typealias PrefixedJsonCodable = PrefixedJsonDecodable & PrefixedJsonEncodable

//public extension PrefixedJsonEncodable {
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encode(PrefixedJson(value: ))
//    }
//}
