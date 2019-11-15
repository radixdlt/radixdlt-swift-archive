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
import Combine
@testable import RadixSDK

class DefaultAtomToTransactionMapperTests: TestCase {
    
    private let alice = AbstractIdentity()
    
    func testTransactionWithSingleCreateTokenActionWithoutInitialSupply() {
        let mapper = DefaultAtomToTransactionMapper.init(identity: alice)
        
        let atom = try! JSONDecoder().decode(Atom.self, from: jsonForCreateTokenXrd.toData())
        let expectation = XCTestExpectation(description: self.debugDescription)
        var transactions = [ExecutedTransaction]()
        let cancellable = mapper.transactionFromAtom(atom)
            .first()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { transactions.append($0) }
        )
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(transactions.count, 1)
        let transaction = transactions[0]
        XCTAssertEqual(transaction.actions.count, 1)
        guard let createTokenAction = transaction.actions.first as? CreateTokenAction else {
            return XCTFail("Transaction is expected to contain exactly one `CreateTokenAction`, nothing else.")
        }
        XCTAssertEqual(createTokenAction.symbol, "XRD")
        XCTAssertEqual(createTokenAction.tokenSupplyType, .fixed)
        
        XCTAssertNotNil(cancellable)
    }
    
}

private let jsonForCreateTokenXrd = """
{
	"metaData": {
		"timestamp": ":str:1551225600000"
	},
	"shards": [
		6245273567170682628
	],
	"hid": ":uid:aee65e30cc0fe4bb5857fb472d2032be",
	"serializer": "radix.atom",
	"version": 100,
	"particleGroups": [
		{
			"serializer": "radix.particle_group",
			"particles": [
				{
					"spin": -1,
					"serializer": "radix.spun_particle",
					"particle": {
						"hid": ":uid:ce31e1c05ff5b8f09cdd7ea23b9ba0c1",
						"destinations": [
							":uid:56abab3870585f04d015d55adf600bc7"
						],
						"rri": ":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/XRD",
						"serializer": "radix.particles.rri",
						"version": 100,
						"nonce": 0
					},
					"version": 100
				},
				{
					"spin": 1,
					"serializer": "radix.spun_particle",
					"particle": {
						"hid": ":uid:9ba72f1e2867aaf9c6e63cd553396ea2",
						"granularity": ":u20:1",
						"destinations": [
							":uid:56abab3870585f04d015d55adf600bc7"
						],
						"rri": ":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/XRD",
						"name": ":str:Rads",
						"serializer": "radix.particles.fixed_supply_token_definition",
						"description": ":str:Radix Native Tokens",
						"iconUrl": ":str:https://assets.radixdlt.com/icons/icon-xrd-32x32.png",
						"version": 100,
						"supply": ":u20:1000000000000000000000000000"
					},
					"version": 100
				},
				{
					"spin": 1,
					"serializer": "radix.spun_particle",
					"particle": {
						"amount": ":u20:1000000000000000000000000000",
						"hid": ":uid:9ff7ae92fe061ee065ddbf6ef04ea966",
						"address": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
						"granularity": ":u20:1",
						"destinations": [
							":uid:56abab3870585f04d015d55adf600bc7"
						],
						"serializer": "radix.particles.transferrable_tokens",
						"version": 100,
						"nonce": 982125088539821,
						"tokenDefinitionReference": ":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/XRD",
						"planck": 25853760
					},
					"version": 100
				}
			],
			"version": 100
		}
	],
	"signatures": {
		"56abab3870585f04d015d55adf600bc7": {
			"r": ":byt:pVigNA0gLFag1OOCj2ytgebZTVFnOhKH7mXAOX5b7RE=",
			"s": ":byt:MHhyojiLwi/CuCILAr//DSx+eQwhK0aiJyji5uhsZrU=",
			"serializer": "crypto.ecdsa_signature",
			"version": 100
		}
	}
}

"""
