//
//  DsonEncodingTokenDefinitionParticleSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-13.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import Nimble
import Quick

class DsonEncodingTokenDefinitionParticleSpec: QuickSpec {
    
    override func spec() {
        describe("DSON encoding") {
            describe("TokenDefinitionParticle") {
                it("should result in the appropriate data") {
                    
                    let tokenDefinitionParticle = TokenDefinitionParticle(
                        symbol: "POW",
                        name: "Proof of Work",
                        description: "Radix POW",
                        address: "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
                        granularity: 1,
                        permissions: [.burn: .none, .mint: .pow, .transfer: .none]
                    )
   
                    let dson = try! tokenDefinitionParticle.toDSON()
                    expect(dson.hex).to(equal(expectedDsonHex))

                }
                
                it("should work from json") {
                    let tokenDefinitionParticle = try! JSONDecoder().decode(TokenDefinitionParticle.self, from: json.data(using: .utf8)!)
                    let dson = try! tokenDefinitionParticle.toDSON()
                    expect(dson.hex).to(equal(expectedDsonHex))
                }
            }
        }
    }
}

private let expectedDsonHex = "bf67616464726573735827040203785a9c259fde9991e44fa2fb0b5659f2a5781ac339076e2dbfef70528e4adf688879c1b96b6465736372697074696f6e69526164697820504f576b6772616e756c61726974795821050000000000000000000000000000000000000000000000000000000000000001646e616d656d50726f6f66206f6620576f726b6b7065726d697373696f6e73bf646275726e646e6f6e65646d696e7463706f77687472616e73666572646e6f6e65ff6a73657269616c697a65723a43a8258d6673796d626f6c63504f576776657273696f6e1864ff"

private let json = """
{
    "symbol": ":str:POW",
    "address": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
    "granularity": ":u20:1",
    "permissions": {
        "burn": ":str:none",
        "mint": ":str:pow",
        "transfer": ":str:none"
    },
    "name": ":str:Proof of Work",
    "serializer": \(RadixModelType.tokenDefinitionParticle.rawValue),
    "description": ":str:Radix POW",
    "version": 100
}
"""
