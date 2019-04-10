//
//  UniverseConfig+Presets.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-09.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension UniverseConfig {
    static var betanet: UniverseConfig {
        return config(fromResource: "betanet")
    }
    static var sunstone: UniverseConfig {
        return config(fromResource: "sunstone")
    }
}

private extension UniverseConfig {
    static func config(fromResource resource: String) -> UniverseConfig {
        guard
            let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
                incorrectImplementation("Config file not found: \(resource)")
        }
        do {
            let data = try Data(contentsOf: url)
            return try
                JSONDecoder().decode(UniverseConfig.self, from: data)
        } catch {
            incorrectImplementation("Failed to create config from data, error: \(error)")
        }
    }
}
