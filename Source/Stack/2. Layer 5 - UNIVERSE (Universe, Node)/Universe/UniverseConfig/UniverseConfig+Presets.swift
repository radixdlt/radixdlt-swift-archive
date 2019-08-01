//
//  UniverseConfig+Presets.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-09.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension UniverseConfig {
    static var localnet: UniverseConfig {
        return config(fromResource: "localnet")        
    }
    
    static var betanet: UniverseConfig {
        return config(fromResource: "betanet")
    }
}

private final class ClassInBundle {}

private extension UniverseConfig {
    static func config(fromResource resource: String) -> UniverseConfig {
        guard
            case let bundle = Bundle(for: ClassInBundle.self),
//            let path = bundle.path(forResource: resource, ofType: "json") else {
            let url = bundle.url(forResource: resource, withExtension: "json") else {
                incorrectImplementation("Config file '\(resource)' not found in Bundle.")
        }
        do {
//            let url = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: url)
            return try
                JSONDecoder().decode(UniverseConfig.self, from: data)
        } catch {
            incorrectImplementation("Failed to create config from data, error: \(error)")
        }
    }
}
