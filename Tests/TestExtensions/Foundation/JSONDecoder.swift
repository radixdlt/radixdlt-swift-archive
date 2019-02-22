//
//  JSONDecoder.swift
//  RadixSDK Tests
//
//  Created by Alexander Cyon on 2019-02-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK

func model<D>(from jsonString: String) -> D where D: Decodable {
    let json = jsonString.data(using: .utf8)!
    do {
        return try JSONDecoder().decode(D.self, from: json)
    } catch {
        print(error)
        incorrectImplementation("error: \(error)")
    }
}
