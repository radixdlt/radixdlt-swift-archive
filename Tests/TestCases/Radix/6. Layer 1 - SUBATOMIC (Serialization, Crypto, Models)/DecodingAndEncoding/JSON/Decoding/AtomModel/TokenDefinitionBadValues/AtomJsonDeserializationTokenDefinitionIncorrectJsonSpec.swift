//
//  AtomJsonDeserializationInvalidJsonKeySpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

private let debugPrintJson = false

typealias JSON = [String: Any]

class AtomJsonDeserializationChangeJson: QuickSpec {
    
    func jsonString() -> String {
        return tokenDefintionJson
    }
    
    lazy var jsonData = self.jsonString().toData()
    
    func replaceValueInParticle(for key: TokenDefinitionParticle.CodingKeys, with replacement: Any) -> String {
      return replaceValueInParticle(for: key.stringValue, with: replacement)
    }
        
    func replaceValueInTokenParticle(for key: UnallocatedTokensParticle.CodingKeys, with replacement: Any) -> String {
        return replaceValueInParticle(for: key.stringValue, with: replacement)
    }
    
    func replaceSpinForSpunParticle(spin: Int) -> String {
        return replaceSpunParticleWithValue { spunParticle in
            var spunParticle = spunParticle
            spunParticle["spin"] = spin
            return spunParticle
        }
    }
}

// MARK: - Private
private extension AtomJsonDeserializationChangeJson {
    
    func replaceValueInParticle(for key: String, with replacement: Any) -> String {
        return replaceValueInParticle { particle in
            var particle = particle
            particle[key.stringValue] = replacement
            return particle
        }
    }
    
    
    func replaceValueInParticle(replaceParticle: (JSON) -> JSON) -> String {
        return replaceSpunParticleWithValue { spunParticle in
            var spunParticle = spunParticle
            let particle = spunParticle["particle"] as! JSON
            spunParticle["particle"] = replaceParticle(particle)
            return spunParticle
        }
    }
    
    func replaceSpunParticleWithValue(makeSpunParticle: (JSON) -> JSON) -> String {
        
        // String to JSON
        var json = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! JSON
        
        // Keys
        let keyParticleGroups = "particleGroups"
        let keyParticles = "particles"
        
        // Read out values
        var particleGroups = json[keyParticleGroups] as! [JSON]
        var particleGroup = particleGroups.first!
        var particles = particleGroup[keyParticles] as! [JSON]
        let spunParticle = particles.first!
        
        particles[0] = makeSpunParticle(spunParticle)
        
        particleGroup[keyParticles] = particles
        particleGroups[0] = particleGroup
        json[keyParticleGroups] = particleGroups
        
        // JSON to String
        let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        let prettyJson = String(data: data)
            .replacingOccurrences(of: "\\\"", with: "\"")
            .replacingOccurrences(of: "\"{", with: "{")
            .replacingOccurrences(of: "}\"", with: "}")
        
        if debugPrintJson {
            print(prettyJson)
        }
        
        return prettyJson
    }
}

private let tokenDefintionJson = """
{
    "\(RadixModelType.jsonKey)": "\(RadixModelType.atom.serializerId)",
    "metaData": {
        "timestamp": ":str:1488326400000"
    },
    "particleGroups": [
        {
            "\(RadixModelType.jsonKey)": "\(RadixModelType.particleGroup.serializerId)",
            "particles": [
                {
                    "\(RadixModelType.jsonKey)": "\(RadixModelType.spunParticle.serializerId)",
                    "spin": 1,
                    "particle": {
                        "\(RadixModelType.jsonKey)": "\(RadixModelType.tokenDefinitionParticle.serializerId)",
                        "symbol": ":str:BAD",
                        "name": ":str:BadCoin",
                        "description": ":str:Some TokenDefinition",
                        "granularity": ":u20:1",
                        "permissions": {
                            "burn": ":str:none",
                            "mint": ":str:none"
                        },
                        "address": ":adr:JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei"
                    }
                }
            ],
            "metaData": {
                "timestamp": ":str:1488326400000"
            }
        }
    ]
}
"""
