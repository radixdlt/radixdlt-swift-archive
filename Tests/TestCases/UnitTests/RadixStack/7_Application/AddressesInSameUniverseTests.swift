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

import XCTest
@testable import RadixSDK

class AddressesInSameUniverseTests: TestCase {


    private var addressUniverse1 = Address.randomUniverse
    private var addressUniverse2 = Address.randomUniverse


    func testDifferentUniverseAddressInSameParticleGroup() {

        XCTAssertThrowsSpecificError(
            try ParticleGroup(spunParticles:
                [
                    UniqueParticle(address: addressUniverse1, string: .irrelevant).withSpin(),
                    UniqueParticle(address: addressUniverse2, string: .irrelevant).withSpin()
                ]
            ),
            ActionsToAtomError.differentUniverses(addresses: Set([addressUniverse1, addressUniverse2]))
        )
    }

    func testDifferentUniverseAddressInDifferentParticleGroups() {

        XCTAssertThrowsSpecificError(
            try ParticleGroups(particleGroups:
                [
                    ParticleGroup(UniqueParticle(address: addressUniverse1, string: .irrelevant).withSpin()),
                    ParticleGroup(UniqueParticle(address: addressUniverse2, string: .irrelevant).withSpin())
                ]
            ),
            ActionsToAtomError.differentUniverses(addresses: Set([addressUniverse1, addressUniverse2]))
        )
    }
    
    func testInSameUniverse() {
        func createAddresses(magic: Magic, count: Int = 4) -> [Address] {
            var addresses = [Address]()
            for _ in 0..<count {
                addresses.append(
                    Address(magic: magic, publicKey: PublicKey(private: PrivateKey.generateNew())))
            }
            return addresses
        }
        
        let address1to9 = createAddresses(magic: 123456789)
        let address9to1 = createAddresses(magic: 987654321)
        XCTAssertNoThrow(try Addresses.allInSameUniverse(address1to9))
        XCTAssertNoThrow(try Addresses.allInSameUniverse(address9to1))
        
        for magicInt in -10..<10 {
            let magic = Magic(integerLiteral: Int32(magicInt))
            for count in 0..<4 {
                XCTAssertNoThrow(try Addresses.allInSameUniverse(createAddresses(magic: magic, count: count)))
            }
        }
        
        let different: [Address] = [address1to9.first!, address9to1.first!, address9to1.last!]
        
        XCTAssertThrowsSpecificError(try Addresses.allInSameUniverse(different), ActionsToAtomError.differentUniverses(addresses: Set(different)))
    }

    func testTransactionSendMessageWrongUniverse() {
        let sendMessageAction = SendMessageAction(from: addressUniverse1, to: addressUniverse2, payload: .empty)

        let transaction = Transaction {
            sendMessageAction
        }

        let mapper = DefaultTransactionToAtomMapper(atomStore: HardCodedAtomStore())
    
        XCTAssertThrowsSpecificError(
            try mapper.atomFrom(transaction: transaction, addressOfActiveAccount: addressUniverse1),
            ActionsToAtomError.differentUniverses(addresses: Set([addressUniverse1, addressUniverse2]))
        )
   
    }
}


extension Address {
    static var randomUniverse: Address {
        let magicInRandomUniverse = Magic(integerLiteral: Int32.random(in: Int32.min...Int32.max))
        return Address(magic: magicInRandomUniverse, publicKey: .irrelevant)
    }
}
