//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

@testable import RadixSDK
import XCTest

class AddressChecksumTests: TestCase {
    
    func testAddressChecksum() {
        
        // GIVEN
        // A public key
        guard let publicKey = XCTAssertNotThrows(
            try PublicKey(hexString: "03000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F")
            ) else { return }
        
        // WHEN
        // I create an address from the public key
        let address = Address(magic: 0x02, publicKey: publicKey)
     
        // THEN
        // a checksum is added to the address
        XCTAssertEqual(
            address.hex,
            "0203000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f175341a9",
            "It should append checksum"
        )
    }

    func testHashIdOfAddress() {
        // GIVEN
        // An address
        let address: Address = "JHB89drvftPj6zVCNjnaijURk8D8AMFw4mVja19aoBGmRXWchnJ"

        // WHEN
        // I calculate it's hashEUID ("hid")
        let hashEUID = address.hashEUID

        // THEN
        // It equals the one produces by the Java lib
        XCTAssertEqual(
            hashEUID,
            "8cfef50ea6a767813631490f9a94f73f",
            "Should equal the value from Java library"
        )
    }
}
