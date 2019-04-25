//
//  AtomWithTrivialMetaDataDsonEncodingSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-15.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Quick
import Nimble

class AtomWithTrivialMetaDataDsonEncodingSpec: QuickSpec {
    
    override func spec() {
        let atomInCode = Atom(metaData: .timestamp("1488326400000"))
        let atomFromJson: Atom = model(from: atomTrivialMetaData)
        
        describe("DSON Encoding of an empty Atom") {
            it("should serialize into correct DSON") {
                
                let dsonFromAtomFromJson = try! atomFromJson.toDSON()
                expect(dsonFromAtomFromJson.hex).to(equal(expectedDsonHex))
                
                let dsonFromCodeAtom = try! atomInCode.toDSON()
                expect(dsonFromCodeAtom.hex).to(equal(expectedDsonHex))
                expect(dsonFromCodeAtom.base64).to(equal(expectedDsonBase64))
                
            }
        }
        
        describe("Radix Hash") {
            it("should match already known") {
                expect(atomInCode.radixHash.hex).to(equal("14bc51478733cb75ffc4bbd85e392bde450ebdcbed102090deb10154a90a0239"))
            }
        }
    }
}

private let expectedDsonHex = "bf686d65746144617461bf6974696d657374616d706d31343838333236343030303030ff6a73657269616c697a65726a72616469782e61746f6d6776657273696f6e1864ff"

private let expectedDsonBase64 = "v2htZXRhRGF0Yb9pdGltZXN0YW1wbTE0ODgzMjY0MDAwMDD/anNlcmlhbGl6ZXJqcmFkaXguYXRvbWd2ZXJzaW9uGGT/"

private let atomTrivialMetaData = """
{
    "serializer": "\(RadixModelType.atom.serializerId)",
    "\(jsonKeyVersion)": \(serializerVersion),
    "metaData": {
        "timestamp": ":str:1488326400000"
    }
}
"""
