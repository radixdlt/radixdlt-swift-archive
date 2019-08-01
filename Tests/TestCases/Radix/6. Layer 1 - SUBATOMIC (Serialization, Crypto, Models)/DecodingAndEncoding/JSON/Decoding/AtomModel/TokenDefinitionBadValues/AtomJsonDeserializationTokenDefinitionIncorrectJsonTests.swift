/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

@testable import RadixSDK
import XCTest

private let debugPrintJson = false

class AtomJsonDeserializationChangeJson: XCTestCase {
    
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
