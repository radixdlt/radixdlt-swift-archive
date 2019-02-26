//
//  StringPrefixedJson.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

//public struct StringPrefixedJson<Value: StringInitializable>: PrefixedJsonDecodable {
//    public let value: Value
//}
//
//// MARK: PrefixedJsonDecodable
//public extension PrefixedJsonDecodable where Self: StringInitializable, Self.From == String {
//    init(from string: String) throws {
//        try self.init(string: string)
//    }
//}
//
//// MARK: PrefixedJsonDecodable
//public extension StringPrefixedJson {
//    static var jsonPrefix: JSONPrefix {
//        return .string
//    }
//    init(from string: String) throws {
//        value = try Value(string: string)
//    }
//    
//    var description: String {
//        return String(describing: value)
//    }
//}
