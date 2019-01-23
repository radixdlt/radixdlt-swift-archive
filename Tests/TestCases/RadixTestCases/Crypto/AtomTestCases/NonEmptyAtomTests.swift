//
//  NonEmptyAtomTests.swift
//  RadixSDKTests
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import XCTest

@testable import RadixSDK

class NonEmptyAtomTests: XCTestCase {
    
    func testAtom() {
        let jsonData = jsonString.data(using: .utf8)!
//        let atom = try! DSONDecoder().decode(data: jsonData, to: Atom.self)
        let atom = try! JSONDecoder().decode(Atom.self, from: jsonData)
        XCTAssertEqual(atom.radixHash.toHexString().value, expectedHash)
    }
}

private let expectedHash = "1b1cff72cb4f79d2eb50b5fb2777d65bebb5cad146e2006f25cde7a53445ffe7"

private let jsonString = """
	{
		"action": ":str:STORE",
		"chronoParticle": {
			"serializer": 1080087081,
			"timestamps": {
				"default": 1539178735739
			},
			"version": 100
		},
		"consumables": [
			{
				"asset_id": ":uid:d7bd34bfe44a18d2aa755a344fe3e6b0",
				"destinations": [
					":uid:c0a9dd141e324d6042372990a1cc1956"
				],
				"nonce": 540608639615663,
				"owners": [
					{
						"public": ":byt:AtdZJj84TD78JkfAvbI2e4YA0GLHIAVTCOzws05Fowu8",
						"serializer": 547221307,
						"version": 100
					}
				],
				"quantity": 10000000,
				"serializer": 318720611,
				"version": 100
			},
			{
				"asset_id": ":uid:d7bd34bfe44a18d2aa755a344fe3e6b0",
				"destinations": [
					":uid:56abab3870585f04d015d55adf600bc7"
				],
				"nonce": 540608639645877,
				"owners": [
					{
						"public": ":byt:A3hanCWf3pmR5E+i+wtWWfKleBrDOQduLb/vcFKOSt9o",
						"serializer": 547221307,
						"version": 100
					}
				],
				"quantity": 99999990000000,
				"serializer": 318720611,
				"version": 100
			},
			{
				"asset_id": ":uid:229c9d7905761d24ea9fafcff64d3d49",
				"destinations": [
					":uid:56abab3870585f04d015d55adf600bc7"
				],
				"nonce": 540608642610988,
				"owners": [
					{
						"public": ":byt:A3hanCWf3pmR5E+i+wtWWfKleBrDOQduLb/vcFKOSt9o",
						"serializer": 547221307,
						"version": 100
					}
				],
				"quantity": 414,
				"serializer": -1463653224,
				"version": 100
			}
		],
		"consumers": [
			{
				"asset_id": ":uid:d7bd34bfe44a18d2aa755a344fe3e6b0",
				"destinations": [
					":uid:56abab3870585f04d015d55adf600bc7"
				],
				"nonce": 508147166233960,
				"owners": [
					{
						"public": ":byt:A3hanCWf3pmR5E+i+wtWWfKleBrDOQduLb/vcFKOSt9o",
						"serializer": 547221307,
						"version": 100
					}
				],
				"quantity": 100000000000000,
				"serializer": 214856694,
				"version": 100
			}
		],
		"dataParticles": [
			{
				"bytes": ":byt:0AGgg7FFonQOWyDN0CbvbSED9Lwy7NQs17U34hb0pu+ds/EIzxoqZ6UkYEWoYYK2Sx0AAAAQ7DvCu1Mw3rAsMW50OroUR26DLNRsdj+3eMYf1KNgMH8MgDlQfVkSDL4/u03SPcro	",
				"serializer": 473758768,
				"version": 100
			},
			{
				"bytes": ":byt:WyJvWE1xTGcvWWtiNStZTjdHUkNKKzFTRUMxdGxGQjhlZ01TdDRrdFM4d2xBbitoT2NlRTVBK25PaGRiWGZGbjd5K2FZQUFBQXd5bFI0SlprVjVmZG15RkdlaTM0bFh5b2VJcDNs	cnBaUnZtSFZNbHY3elBWWFQyR3JJM1dIV1hjbm9GOGhBZHUvWjNQc001OEpJYURHMWtjejBGTnVFYm5STjdsZmNEVU8yUlUrR1lSSi9kWT0iLCIzNnFydmlvWEMzY2xUUldhcFFmSVlDRUNvekFtSkp	pdjRYUHRUNC9MejNOZEtHaFI3VzFsaGozaU5pbm5wUC9qY0JFQUFBQXdhdVdBeElMSUNqVUlsRGR5dnNBOEVRemZCLzhXUFI3OXlmNC9CdjdXeWtPSS85cXhYWWpacjlMN05pRFRhcGFhUU1VaEtpeE	puRldORDZtU05kQVdpMS9BbGYvbjQxVjQ5dFJzejNZZUQ4bz0iXQ==",
				"metaData": {
					"application": ":str:encryptor",
					"contentType": ":str:application/json"
				},
				"serializer": 473758768,
				"version": 100
			}
		],
		"destinations": [
			":uid:56abab3870585f04d015d55adf600bc7",
			":uid:c0a9dd141e324d6042372990a1cc1956"
		],
		"serializer": 2019665,
		"signatures": {
			"56abab3870585f04d015d55adf600bc7": {
				"r": ":byt:AL3/nYW7FGVRNndA3x1tRBS4vfPKrGHLKTGwcDEhYCcp",
				"s": ":byt:AIDk+93m2xSNpBO6WO+Pim25k0uyqaBf8E1TwRhOZfcm",
				"serializer": -434788200,
				"version": 100
			}
		},
		"version": 100
	}
"""
