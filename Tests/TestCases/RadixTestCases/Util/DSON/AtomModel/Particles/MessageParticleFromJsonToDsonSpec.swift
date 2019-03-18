
//
//  MessageParticleFromJsonToDsonSpec.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-15.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import Nimble
import Quick

class MessageParticleFromJsonToDsonSpec: QuickSpec {
    override func spec() {
        let messageParticle: MessageParticle = model(from: messageParticleJSON)
        describe("MessageParticle JSON Deserialization") {
            it("should serialize into correct DSON") {
                let dson = try! messageParticle.toDSON()
                expect(dson.hex).to(equal("bf656279746573570152616469782e2e2e206a75737420696d6167696e65216466726f6d5827040203785a9c259fde9991e44fa2fb0b5659f2a5781ac339076e2dbfef70528e4adf688879c1b96a73657269616c697a65723a4ac1ec9262746f5827040203785a9c259fde9991e44fa2fb0b5659f2a5781ac339076e2dbfef70528e4adf688879c1b96776657273696f6e1864ff"))
            }
        }
    }
}

private let messageParticleJSON = """
{
	"bytes": ":byt:UmFkaXguLi4ganVzdCBpbWFnaW5lIQ==",
	"from": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
	"serializer": -1254222995,
	"to": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
	"version": 100
}
"""
