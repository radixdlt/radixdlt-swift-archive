//
//  Enviroment.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum Enviroment: String {
    case localhost = "http://127.0.0.1:8080/api"
}

public extension Enviroment {
    var baseURL: URL {
        guard let url = URL(string: rawValue) else {
            incorrectImplementation("Failed to create url")
        }
        return url
    }
}
