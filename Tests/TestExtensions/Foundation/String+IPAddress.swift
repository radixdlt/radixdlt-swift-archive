//
//  String+IPAddress.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

extension String {
    var looksLikeAnIPAddress: Bool {
        if contains("localhost") {
            return true
        }
        return components(separatedBy: ".").count == 4
    }
}
