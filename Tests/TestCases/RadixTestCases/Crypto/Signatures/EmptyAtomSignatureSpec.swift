//
//  EmptyAtomSignatureSpec.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import RadixSDK

class EmptyAtomSignatureSpec: QuickSpec {
    override func spec() {
        let atom = Atom(metaData: ChronoMetaData.timestamp(0))
        describe("Radix Hash Id") {
            it("should match Java") {
                expect(atom.hashId).to(equal("e50964da69e6672a98d5e3c1b1d73fb3"))
            }
        }
        describe("ECC") {
            it("should match Java signature") {
                let privateKey = try! PrivateKey(data: Sha256Hasher().hash(data: "Radix".toData()))
                let signature = try! Signer.sign(atom, privateKey: privateKey)
                expect(signature.r.hex).to(equal("d58c086f3d79a4159241df186306ff21627f09d718820a886110ee927dfc6682"))
                expect(signature.s.hex).to(equal("63a573d3255f529310c6db9a985b01cba72fdcf4236b1e12f64ecac2e2ddce14"))
            }
        }
    }
}
