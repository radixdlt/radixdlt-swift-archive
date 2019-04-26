//
//  DSONEncodingAddressHolderSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//


@testable import RadixSDK
import XCTest


class DSONEncodingAddressHolderTests: XCTestCase {

    struct AddressHolder: RadixCodable {
        public let address: Address
        public enum CodingKeys: String, CodingKey {
            case address
            case serializer, version
        }
        public func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] { return
            [
                EncodableKeyValue(key: .address, value: address),
                EncodableKeyValue(key: .serializer, value: -1322468736)
            ]
        }
    }
    
    func testDsonEncodingOfAddressHolder() {
        // GIVEN
        // A public key...
        guard let publicKey = XCTAssertNotThrows(
            try PublicKey(hexString: "03000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F")
        ) else { return }
        
        // ... used to create an instance of `AddressHolder` (DSON encodable)
        let addressHolder = AddressHolder(
            address: Address(
                magic: 0x02,
                publicKey: publicKey
            )
        )
        
        // WHEN
        // I DSON encode it
        guard let dson = dsonOrFail(addressHolder) else { return }
        
        // THEN
        // It matches the HexString calculated by the Java library
        XCTAssertEqual(
            dson.hex,
            "bf67616464726573735827040203000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f175341a96a73657269616c697a65723a4ed3457f6776657273696f6e1864ff",
            "It matches Java lib"
        )
        
        // ... and the Base64 string also matches
        XCTAssertEqual(
            dson.base64,
            "v2dhZGRyZXNzWCcEAgMAAQIDBAUGBwgJCgsMDQ4PEBESExQVFhcYGRobHB0eHxdTQalqc2VyaWFsaXplcjpO00V/Z3ZlcnNpb24YZP8=",
            "It matches Java lib"
        )
    }
}
