//
//  DsonEncodingMintedTokenParticle.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import Nimble
import Quick
import BigInt

class BigUnsignedIntTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
//    func testNumbers() {
//
//        for i in 1...10000 {
//            let bigInt = BigUInt(integerLiteral: UInt64(i))
//            let data = bigInt.asData
//            let cryptoSwiftHex = data.toHexString()
//            let radixHex = data.toHexString(uppercased: false).stringValue
//            let radixHexViaHexString = bigInt.toHexString(uppercased: false).stringValue
//            XCTAssertEqual(cryptoSwiftHex, radixHex)
//            print("cryptoSwiftHex: `\(cryptoSwiftHex)`")
//            print("radixHexViaHexString: `\(radixHexViaHexString)`")
//            XCTAssertEqual(cryptoSwiftHex, radixHexViaHexString)
//        }
//    }
    
    func testUint256() {
        let table = [
            "10": "A",
            "100": "64",
            "1000": "3E8",
            "10000": "2710",
            "100000": "186A0",
            "1000000": "F4240",
            "10000000": "989680",
            "100000000": "5F5E100",
            "1000000000": "3B9ACA00",
        ]
        for (key, value) in table {
            let bigInt = BigUnsignedInt(stringLiteral: key)
            
            XCTAssertEqual(bigInt.toHexString(uppercased: true).stringValue, value)
            XCTAssertEqual(bigInt.asData.toHexString(uppercased: true, mode: .trim).stringValue, value)
            XCTAssertEqual(bigInt.toBase64String().asData.toHexString(uppercased: true, mode: .trim).stringValue, value)
            XCTAssertEqual(bigInt.asData.toBase64String().toHexString(uppercased: true, mode: .trim).stringValue, value)
            
//            let bigIntFromDataAndBack: String = try! Base58String(hexString: bigIntToHex).toHexString(uppercased: true, mode: .trim).stringValue
//            XCTAssertEqual(bigIntFromDataAndBack, value)
        }
//        var decimalBase = "1"
//        while decimalBase.length < 30 {
//            decimalBase += "0"
//            let bigUint = BigUnsignedInt(stringLiteral: decimalBase)
//
//        }
    }
}

class DsonEncodingMintedTokenParticle: QuickSpec {
    
    override func spec() {
        describe("DSON encoding") {
            
            it("hex of int") {
                let bigInt: BigUnsignedInt = "1000000000000000000000000000"

                expect(bigInt.toHexString(uppercased: false, mode: .trim)).to(equal("33b2e3c9fd0803ce8000000"))
//                expect(bigInt.asData.hex).to(equal("33b2e3c9fd0803ce8000000"))
            }
            
            it("should be possible to encode UInt256") {
                let gran1: Granularity = 1
                expect(try! gran1.toDSON().hex).to(equal("5821050000000000000000000000000000000000000000000000000000000000000001"))
                 let gran2: Granularity = "1000000000000000000000000000"
                expect(try! gran2.toDSON().hex).to(equal("5821050000000000000000000000000000000000000000033b2e3c9fd0803ce8000000"))
            }
            
            describe("MintedTokenParticle") {
                it("should result in the appropriate data") {
                    
                    let tokenParticle = try! JSONDecoder().decode(TokenParticle.self, from: mintedTokenParticleJson.data(using: .utf8)!)
                    expect(tokenParticle.tokenType).to(equal(.minted))
                    let dson = try! tokenParticle.toDSON()
             
                    expect(dson.hex).to(equal(expectedDsonHex))
                    expect(dson.base64).to(equal(expectedDsonBase64))
                }
            }
        }
    }
}

private let expectedDsonBase64 = "v2dhZGRyZXNzWCcEAgN4Wpwln96ZkeRPovsLVlnypXgawzkHbi2/73BSjkrfaIh5wblmYW1vdW50WCEFAAAAAAAAAAAAAAAAAAAAAAAAAAADOy48n9CAPOgAAABrZ3JhbnVsYXJpdHlYIQUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWVub25jZRsAAnrs5kJZKWZwbGFuY2saAXqAQGpzZXJpYWxpemVyGmgDvOFydG9rZW5UeXBlUmVmZXJlbmNlWEYGL0pIMVA4ZjN6bmJ5ckRqOEY0UldwaXg3aFJrZ3hxSGpkVzJmTm5LcFIzdjZ1Zlhua25vci90b2tlbmNsYXNzZXMvWFJEZ3ZlcnNpb24YZP8="

private let expectedDsonHex = "bf67616464726573735827040203785a9c259fde9991e44fa2fb0b5659f2a5781ac339076e2dbfef70528e4adf688879c1b966616d6f756e745821050000000000000000000000000000000000000000033b2e3c9fd0803ce80000006b6772616e756c61726974795821050000000000000000000000000000000000000000000000000000000000000001656e6f6e63651b00027aece642592966706c616e636b1a017a80406a73657269616c697a65721a6803bce172746f6b656e547970655265666572656e63655846062f4a4831503866337a6e627972446a38463452577069783768526b677871486a645732664e6e4b70523376367566586e6b6e6f722f746f6b656e636c61737365732f5852446776657273696f6e1864ff"

private let mintedTokenParticleJson = """
{
    "address": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
    "amount": ":u20:1000000000000000000000000000",
    "granularity": ":u20:1",
    "nonce": 698107847399721,
    "planck": 24805440,
    "serializer": 1745075425,
    "tokenTypeReference": ":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/tokenclasses/XRD",
    "version": 100
}
"""
