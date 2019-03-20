//
//  AddressChecksumSpec.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick


class AddressChecksumSpec: QuickSpec {
    
    override func spec() {
        describe("Address Checksum") {
            it("Should be appended to publickey") {
                let publicKey = try! PublicKey(hexString: "03000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F")
                let address = Address(magic: 0x02, publicKey: publicKey)
                expect(address.hex).to(equal("0203000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f175341a9"))
                
            }
        }
    }
}
