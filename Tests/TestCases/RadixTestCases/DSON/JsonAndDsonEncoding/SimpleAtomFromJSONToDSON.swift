//
//  SimpleAtomFromJSONToDSON.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-15.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Quick
import Nimble

class SimpleAtomFromJSONToDSONSpec: QuickSpec {
    
    override func spec() {
        let atom: Atom = model(from: jsonString)
        describe("Deserialized Atom") {
            it("should contain two empty particlegroups") {
                expect(atom.particleGroups.count).to(equal(1))
            }
        }

        describe("DSON encoding Output == All") {
            describe("DSON Hex") {
                let dson = try! atom.toDSON()
                it("should serialize into correct DSON") {
                    expect(dson.hex).to(equal(expectedDsonAllHex))
                }
            }
        }
        
        describe("Radix Hash") {
            describe("DSON Hash Hex") {
                let dson = try! atom.toDSON(output: .hash)
                it("should serialize into correct DSON") {
                    expect(dson.hex).to(equal(expectedDsonHashHex))
                }
            }
            it("should match Java library") {
                expect(atom.radixHash.hex).to(equal("6a7838c881e9303d0e3ee23563533a7881b5385748e95687e584e8f111122de1"))
            }
        }
    }
}

private let expectedDsonAllHex = "bf686d65746144617461bf6974696d657374616d706d31343838333236343030303030ff6e7061727469636c6547726f75707381bf6a73657269616c697a65723a03ff3c666776657273696f6e1864ff6a73657269616c697a65721a001ed1516a7369676e617475726573bf78203731633363326663396665653733623133636164303832383030613664306465bf617258210125150b1a4996cf1571d00b4ef0d62667402a6e2ea11bf563e867a80774ef1c05617358210129b282c87c3d1983fa1328dbc9069c917b45e078fb0a05f67e64e5b60e555fd16a73657269616c697a65723a19ea57676776657273696f6e1864ffff6776657273696f6e1864ff"

private let expectedDsonHashHex = "bf686d65746144617461bf6974696d657374616d706d31343838333236343030303030ff6e7061727469636c6547726f75707381bf6a73657269616c697a65723a03ff3c666776657273696f6e1864ff6a73657269616c697a65721a001ed1516776657273696f6e1864ff"

private let signatureHuidHex = "71c3c2fc9fee73b13cad082800a6d0de"

private let jsonString = """
{
    "metaData": {
        "timestamp": ":str:1488326400000"
    },
    "particleGroups": [
        {
            "particles": [],
            "serializer": -67058791,
            "\(jsonKeyVersion)": \(serializerVersion)
        }
    ],
    "serializer": 2019665,
    "signatures": {
        "\(signatureHuidHex)": {
            "r":":byt:JRULGkmWzxVx0AtO8NYmZ0Aqbi6hG/Vj6GeoB3TvHAX=",
            "s":":byt:KbKCyHw9GYP6EyjbyQackXtF4Hj7CgX2fmTltg5VX9H=",
            "serializer": -434788200,
            "\(jsonKeyVersion)": \(serializerVersion)
        }
    },
    "\(jsonKeyVersion)": \(serializerVersion)
}
"""
