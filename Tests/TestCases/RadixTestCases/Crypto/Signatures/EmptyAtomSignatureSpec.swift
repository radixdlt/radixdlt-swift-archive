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
                expect(atom.hashId).to(equal("823e52dbdbcf7c91ea100f03b68ead29"))
            }
        }
        describe("ECC") {
            it("should match Java signature") {
                let privateKey = try! PrivateKey(data: Sha256Hasher().hash(data: "Radix".toData()))
                let signature = try! Signer.sign(atom, privateKey: privateKey)
                expect(signature.r.hex).to(equal("a16a6928b53af3a441f7248407e53f898ee7bda2911658d530306d3485d98f65"))
                expect(signature.s.hex).to(equal("7173a93790ce2b550ad484582c879bb7fea3113891b3ad9dca6a5b31471a580c"))
            }
        }
    }
}
