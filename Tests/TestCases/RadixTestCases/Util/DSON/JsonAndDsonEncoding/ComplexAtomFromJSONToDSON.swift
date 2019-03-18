//
//  ComplexAtomFromJSONToDSON.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Quick
import Nimble

class ComplexAtomFromJSONToDSONSpec: QuickSpec {
    override func spec() {
        describe("Atom JSON Deserialization") {
            let atom: Atom = model(from: atomJson)
            print(atom)
            it("should deserialize into an Atom") {
                expect(atom.particles(spin: .up, type: MintedTokenParticle.self).first?.identifier.unique).to(equal("XRD"))
            }
            it("should serialize into correct DSON") {
                let dson = try! atom.toDSON()
                expect(dson.hex).to(equal(expectedDsonHex))
                expect(dson.base64).to(equal(expecteDsonBase64))
            }
        }
    }
}

private let expectedDsonHex = "bf686d65746144617461bf6974696d657374616d706d31343838333236343030303030ff6e7061727469636c6547726f75707382bf697061727469636c657381bf687061727469636c65bf656279746573570152616469782e2e2e206a75737420696d6167696e65216466726f6d5827040203785a9c259fde9991e44fa2fb0b5659f2a5781ac339076e2dbfef70528e4adf688879c1b96a73657269616c697a65723a4ac1ec9262746f5827040203785a9c259fde9991e44fa2fb0b5659f2a5781ac339076e2dbfef70528e4adf688879c1b96776657273696f6e1864ff6a73657269616c697a65723a3b30c5c3647370696e016776657273696f6e1864ff6a73657269616c697a65723a03ff3c666776657273696f6e1864ffbf697061727469636c657382bf687061727469636c65bf67616464726573735827040203785a9c259fde9991e44fa2fb0b5659f2a5781ac339076e2dbfef70528e4adf688879c1b966616d6f756e745821050000000000000000000000000000000000000000033b2e3c9fd0803ce80000006b6772616e756c61726974795821050000000000000000000000000000000000000000000000000000000000000001656e6f6e63651b00027aece642592966706c616e636b1a017a80406a73657269616c697a65721a6803bce17818746f6b656e446566696e6974696f6e5265666572656e63655840062f4a4831503866337a6e627972446a38463452577069783768526b677871486a645732664e6e4b70523376367566586e6b6e6f722f746f6b656e732f5852446776657273696f6e1864ff6a73657269616c697a65723a3b30c5c3647370696e016776657273696f6e1864ffbf687061727469636c65bf67616464726573735827040203785a9c259fde9991e44fa2fb0b5659f2a5781ac339076e2dbfef70528e4adf688879c1b96b6465736372697074696f6e69526164697820504f576b6772616e756c61726974795821050000000000000000000000000000000000000000000000000000000000000001646e616d656d50726f6f66206f6620576f726b6b7065726d697373696f6e73bf646275726e646e6f6e65646d696e7463706f77687472616e73666572646e6f6e65ff6a73657269616c697a65723a43a8258d6673796d626f6c63504f576776657273696f6e1864ff6a73657269616c697a65723a3b30c5c3647370696e016776657273696f6e1864ff6a73657269616c697a65723a03ff3c666776657273696f6e1864ff6a73657269616c697a65721a001ed1516a7369676e617475726573bf78203731633363326663396665653733623133636164303832383030613664306465bf617258210125150b1a4996cf1571d00b4ef0d62667402a6e2ea11bf563e867a80774ef1c05617358210129b282c87c3d1983fa1328dbc9069c917b45e078fb0a05f67e64e5b60e555fd16a73657269616c697a65723a19ea57676776657273696f6e1864ffff6776657273696f6e1864ff"

private let expecteDsonBase64 = "v2htZXRhRGF0Yb9pdGltZXN0YW1wbTE0ODgzMjY0MDAwMDD/bnBhcnRpY2xlR3JvdXBzgr9pcGFydGljbGVzgb9ocGFydGljbGW/ZWJ5dGVzVwFSYWRpeC4uLiBqdXN0IGltYWdpbmUhZGZyb21YJwQCA3hanCWf3pmR5E+i+wtWWfKleBrDOQduLb/vcFKOSt9oiHnBuWpzZXJpYWxpemVyOkrB7JJidG9YJwQCA3hanCWf3pmR5E+i+wtWWfKleBrDOQduLb/vcFKOSt9oiHnBuWd2ZXJzaW9uGGT/anNlcmlhbGl6ZXI6OzDFw2RzcGluAWd2ZXJzaW9uGGT/anNlcmlhbGl6ZXI6A/88Zmd2ZXJzaW9uGGT/v2lwYXJ0aWNsZXOCv2hwYXJ0aWNsZb9nYWRkcmVzc1gnBAIDeFqcJZ/emZHkT6L7C1ZZ8qV4GsM5B24tv+9wUo5K32iIecG5ZmFtb3VudFghBQAAAAAAAAAAAAAAAAAAAAAAAAAAAzsuPJ/QgDzoAAAAa2dyYW51bGFyaXR5WCEFAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFlbm9uY2UbAAJ67OZCWSlmcGxhbmNrGgF6gEBqc2VyaWFsaXplchpoA7zheBh0b2tlbkRlZmluaXRpb25SZWZlcmVuY2VYQAYvSkgxUDhmM3puYnlyRGo4RjRSV3BpeDdoUmtneHFIamRXMmZObktwUjN2NnVmWG5rbm9yL3Rva2Vucy9YUkRndmVyc2lvbhhk/2pzZXJpYWxpemVyOjswxcNkc3BpbgFndmVyc2lvbhhk/79ocGFydGljbGW/Z2FkZHJlc3NYJwQCA3hanCWf3pmR5E+i+wtWWfKleBrDOQduLb/vcFKOSt9oiHnBuWtkZXNjcmlwdGlvbmlSYWRpeCBQT1drZ3JhbnVsYXJpdHlYIQUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWRuYW1lbVByb29mIG9mIFdvcmtrcGVybWlzc2lvbnO/ZGJ1cm5kbm9uZWRtaW50Y3Bvd2h0cmFuc2ZlcmRub25l/2pzZXJpYWxpemVyOkOoJY1mc3ltYm9sY1BPV2d2ZXJzaW9uGGT/anNlcmlhbGl6ZXI6OzDFw2RzcGluAWd2ZXJzaW9uGGT/anNlcmlhbGl6ZXI6A/88Zmd2ZXJzaW9uGGT/anNlcmlhbGl6ZXIaAB7RUWpzaWduYXR1cmVzv3ggNzFjM2MyZmM5ZmVlNzNiMTNjYWQwODI4MDBhNmQwZGW/YXJYIQElFQsaSZbPFXHQC07w1iZnQCpuLqEb9WPoZ6gHdO8cBWFzWCEBKbKCyHw9GYP6EyjbyQackXtF4Hj7CgX2fmTltg5VX9Fqc2VyaWFsaXplcjoZ6ldnZ3ZlcnNpb24YZP//Z3ZlcnNpb24YZP8="

private let atomJson = """
{
    "metaData": {
        "timestamp": ":str:1488326400000"
    },
    "particleGroups": [
        {
            "particles": [
                {
                    "particle": {
                        "bytes": ":byt:UmFkaXguLi4ganVzdCBpbWFnaW5lIQ==",
                        "from": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
                        "serializer": \(RadixModelType.messageParticle.rawValue),
                        "to": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
                        "version": 100
                    },
                    "serializer": \(RadixModelType.spunParticle.rawValue),
                    "spin": 1,
                    "version": 100
                }
            ],
            "serializer": \(RadixModelType.particleGroup.rawValue),
            "version": 100
        },
        {
            "particles": [
                {
                    "particle": {
                        "address": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
                        "amount": ":u20:1000000000000000000000000000",
                        "granularity": ":u20:1",
                        "nonce": 698107847399721,
                        "planck": 24805440,
                        "serializer": \(RadixModelType.mintedTokenParticle.rawValue),
                        "tokenDefinitionReference": ":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/tokens/XRD",
                        "version": 100
                    },
                    "serializer": \(RadixModelType.spunParticle.rawValue),
                    "spin": 1,
                    "version": 100
                },
                {
                    "particle": {
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
                    },
                    "serializer": \(RadixModelType.spunParticle.rawValue),
                    "spin": 1,
                    "version": 100
                }
            ],
            "serializer": \(RadixModelType.particleGroup.rawValue),
            "version": 100
        }
    ],
    "serializer": \(RadixModelType.atom.rawValue),
    "signatures": {
        "71c3c2fc9fee73b13cad082800a6d0de": {
            "r":":byt:JRULGkmWzxVx0AtO8NYmZ0Aqbi6hG/Vj6GeoB3TvHAX=",
            "s":":byt:KbKCyHw9GYP6EyjbyQackXtF4Hj7CgX2fmTltg5VX9H=",
            "serializer": \(RadixModelType.signature.rawValue),
            "version": 100
        }
    },
    "version": 100
}
"""
