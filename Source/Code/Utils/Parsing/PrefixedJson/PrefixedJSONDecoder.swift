//
//  PrefixedJSONDecoder.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public typealias JSONDecoder = PrefixedJSONDecoder
public class PrefixedJSONDecoder: Foundation.JSONDecoder {
    
}

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

public protocol PrefixedValueDecodingContainer

// public struct KeyedDecodingContainer<K> : KeyedDecodingContainerProtocol where
// public protocol SingleValueDecodingContainer {
// public protocol UnkeyedDecodingContainer {

