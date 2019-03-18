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


class RadixModelTypeSerializerSpec: QuickSpec {
    override func spec() {
        describe("Serializer value") {
            it("Should equal hashCode of uppercase name in the Java world") {
                expect(RadixModelType.signature.rawValue).to(equal(JavaHash.from("SIGNATURE")))
                expect(-1322468736).to(equal(JavaHash.from("ADDRESSHOLDER")))
            }
        }
    }
}

class DSONEncodingAddressHolderSpec: QuickSpec {
    
    let address = Address(
        magic: 0x02,
        publicKey: try! PublicKey(hexString: "03000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F")
    )
    
    struct AddressHolder: RadixCodable {
        public let address: Address
        public enum CodingKeys: String, CodingKey {
            case address
            case type = "serializer"
            case version
        }
        public func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] { return
            [
                EncodableKeyValue(key: .address, value: address),
                EncodableKeyValue(key: .type, value: -1322468736),
            ]
        }
    }
    
    override func spec() {
        let addressHolder = AddressHolder(address: address)
        describe("DSON encoding - AddressHolder") {
            it("should result in the appropriate data") {
                let addressHolderDsonEncoded = try! addressHolder.toDSON()
                expect(addressHolderDsonEncoded.hex)
                    .to(equal("bf67616464726573735827040203000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f175341a96a73657269616c697a65723a4ed3457f6776657273696f6e1864ff"))
                expect(addressHolderDsonEncoded.toBase64String()).to(equal("v2dhZGRyZXNzWCcEAgMAAQIDBAUGBwgJCgsMDQ4PEBESExQVFhcYGRobHB0eHxdTQalqc2VyaWFsaXplcjpO00V/Z3ZlcnNpb24YZP8="))
                
            }
        }
    }
}
