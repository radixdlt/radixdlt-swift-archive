//
//  DSONEncodingAddressHolderSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//


@testable import RadixSDK
import Nimble
import Quick


class DSONEncodingAddressHolderSpec: QuickSpec {
    
    let address = Address(
        magic: 0x02,
        publicKey: try! PublicKey(hexString: "03000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F")
    )
    
    struct AddressHolder: CBORStreamable {
        public let address: Address
        public enum CodingKeys: String, CodingKey {
            case address
        }
        public var keyValues: [EncodableKeyValue<CodingKeys>] { return [EncodableKeyValue(key: .address, value: address)] }
    }
    
    override func spec() {
        let addressHolder = AddressHolder(address: address)
        describe("DSON encoding - AddressHolder") {
            it("should result in the appropriate data") {
                let addressHolderDsonEncoded = addressHolder.toDSON()
                expect(addressHolderDsonEncoded.hex)
                    .to(equal("bf67616464726573735827040203000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f175341a9ff"))
                expect(addressHolderDsonEncoded.toBase64String()).to(equal("v2dhZGRyZXNzWCcEAgMAAQIDBAUGBwgJCgsMDQ4PEBESExQVFhcYGRobHB0eHxdTQan/"))
                
            }
        }
    }
}
