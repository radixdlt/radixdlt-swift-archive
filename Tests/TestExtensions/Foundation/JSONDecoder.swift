//
//  RadixJSONDecoder.swift
//  RadixSDK Tests
//
//  Created by Alexander Cyon on 2019-02-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK

@discardableResult
func model<D>(from jsonString: String) -> D where D: Decodable & RadixModelTypeStaticSpecifying {
    do {
        return try decode(D.self, from: jsonString)
    } catch {
        print(error)
        incorrectImplementation("error: \(error)")
    }
}

@discardableResult
func decode<D>(_ type: D.Type, from jsonString: String) throws -> D where D: Decodable & RadixModelTypeStaticSpecifying {
    let json = jsonString.data(using: .utf8)!
    return try RadixJSONDecoder().decode(D.self, from: json)
}
