//
//  AtomJsonDeserializationUnallocatedTokenBadValuesTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class AtomJsonDeserializationUnallocatedTokenBadValuesTests: AtomJsonDeserializationChangeJson {
        
    override func jsonString() -> String {
        return """
            {
                "\(RadixModelType.jsonKey)": "\(RadixModelType.atom.serializerId)",
                "signatures": {},
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
                                    "\(RadixModelType.jsonKey)": "\(RadixModelType.unallocatedTokensParticle.serializerId)",
                                    "granularity": ":u20:1",
                                    "nonce": 992284943125945,
                                    "permissions": {
                                        "mint": ":str:token_creation_only",
                                        "burn": ":str:none"
                                    },
                                    "amount": ":u20:100000",
                                    "tokenDefinitionReference": ":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnkntokens/XRD"
                                }
                            }
                        ],
                        "metaData": {}
                    }
                ]
            }
        """
    }
}
