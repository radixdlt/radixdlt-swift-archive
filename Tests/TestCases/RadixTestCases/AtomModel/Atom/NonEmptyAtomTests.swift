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
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func testAtomConsistingOfThreeParticleGroups() {
        do {
            let jsonData = jsonStringThreeParticleGroups.data(using: .utf8)!
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            let atom = try decoder.decode(Atom.self, from: jsonData)
            XCTAssertEqual(atom.particleGroups.count, 3)
            
            // GROUP 0
            let group0 = atom.particleGroups[0]
            XCTAssertEqual(group0.spunParticles.count, 2)
            XCTAssertEqual(group0.spunParticles[0].spin, .up)
            XCTAssertEqual(group0.spunParticles[1].spin, .up)
            // G0: PARTICLE 0
            guard let g0p0TokP = group0.spunParticles[0].particle as? TokenParticle else {
                return XCTFail("should be token particle")
            }
            XCTAssertEqual(g0p0TokP.description, "The Best Coin Ever")
            XCTAssertEqual(g0p0TokP.quarks.count, 3)
            XCTAssertEqual(g0p0TokP.permissions.count, 3)
            let permissions = g0p0TokP.permissions
            XCTAssertEqual(permissions[.mint], .tokenOwnerOnly)
            XCTAssertEqual(permissions[.burn], .tokenOwnerOnly)
            XCTAssertEqual(permissions[.transfer], .all)
            
            let g0p0IdQ = g0p0TokP.quarks[0] as! IdentifiableQuark
            XCTAssertEqual(g0p0IdQ.identifier, "/JHd1zCEKkXMhwz7GgSuENRrcFpPKveWugkFCn4u1NCqfc629zH6/tokenclasses/JOSH")
            
            let g0p0AccQ = g0p0TokP.quarks[1] as! AccountableQuark
            XCTAssertEqual(g0p0AccQ.addresses.count, 1)
            let address = g0p0AccQ.addresses[0]
            XCTAssertEqual(address.hex, "0203c944bd6aa376389cf56d0bc5ed2a157a581caeb632d0cd2d26b6fb168ff70d065cd0c6d9")
            
            let g0p0OwnQ = g0p0TokP.quarks[2] as! OwnableQuark
            XCTAssertEqual(g0p0OwnQ.owner.toHexString(), "03c944bd6aa376389cf56d0bc5ed2a157a581caeb632d0cd2d26b6fb168ff70d06")
            XCTAssertEqual(g0p0OwnQ.owner.toBase64String(), "A8lEvWqjdjic9W0Lxe0qFXpYHK62MtDNLSa2+xaP9w0G")
            
            // G0: PARTICLE 1
            guard let g0p1OwnP = group0.spunParticles[1].particle as? OwnedTokensParticle else {
                return XCTFail("should be OwnedTokensParticle")
            }
            
            XCTAssertEqual(g0p1OwnP.granularity, 1)
            XCTAssertEqual(g0p1OwnP.tokenReference, "/JHd1zCEKkXMhwz7GgSuENRrcFpPKveWugkFCn4u1NCqfc629zH6/tokenclasses/JOSH")
            XCTAssertEqual(g0p1OwnP.quarks.count, 3)
            
            let g0p1FunQ = g0p1OwnP.quarks[2] as! FungibleQuark
            XCTAssertEqual(g0p1FunQ.amount, "10000000000000000000000")
            XCTAssertEqual(g0p1FunQ.nonce, 1548325112815)
            XCTAssertEqual(g0p1FunQ.planck, 25865418)
            XCTAssertEqual(g0p1FunQ.type, .minted)
            
            // GROUP 1
            let group1 = atom.particleGroups[1]
            XCTAssertEqual(group1.spunParticles.count, 1)
            XCTAssertEqual(group1.spunParticles[0].spin, .up)
            let g1p0TimeP = group1.spunParticles[0].particle as! TimestampParticle
            XCTAssertNotNil(g1p0TimeP.timestamp())
            XCTAssertEqual(g1p0TimeP.quarks.count, 1)
            let g1p0ChrQ = g1p0TimeP.quarks[0] as! ChronoQuark
            XCTAssertEqual(g1p0ChrQ.timestamps.count, 1)
            XCTAssertEqual(g1p0TimeP.timestamp(), g1p0ChrQ.timestamps[.default])
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            XCTAssertEqual(dateFormatter.string(from: g1p0TimeP.timestamp()!), "2019-01-24")
            
            // GROUP 2
            let group2 = atom.particleGroups[2]
            XCTAssertEqual(group2.spunParticles.count, 1)
            XCTAssertEqual(group2.spunParticles[0].spin, .up)
            let g2p0FeeP = group2.spunParticles[0].particle as! FeeParticle
            XCTAssertEqual(g2p0FeeP.granularity, 1)
            XCTAssertEqual(g2p0FeeP.tokenReference, "/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/tokenclasses/POW")
            XCTAssertEqual(g2p0FeeP.service, "00000000000000000000000000000001")
            XCTAssertEqual(g2p0FeeP.quarks.count, 3)
            let g2p0q3FunQ = g2p0FeeP.quarks[2] as! FungibleQuark
            XCTAssertEqual(g2p0q3FunQ.amount, 34991)
            XCTAssertEqual(g2p0q3FunQ.type, .minted)
            XCTAssertEqual(g2p0q3FunQ.nonce, 1887866948436064)
            XCTAssertEqual(g2p0q3FunQ.planck, 25865418)
            
//            XCTAssertEqual(atom.radixHash.toHexString().value, expectedHash)
        } catch {
            return XCTFail("error: \(error)")
        }
    }
}

private let expectedHash = "2d8227aa5097ac892ba57fa7dc466f2433ac036df668fba212cb10361d275278"
private let jsonStringThreeParticleGroups = """
{
	"version":100,
	"serializer":2019665,
	"particleGroups":[
		{
			"version":100,
			"serializer":-67058791,
			"particles":[
				{
					"version":100,
					"serializer":-993052100,
					"particle":{
						"version":100,
						"serializer":-1034420571,
						"quarks":[
							{
								"version":100,
								"serializer":1697220864,
								"id":":rri:/JHd1zCEKkXMhwz7GgSuENRrcFpPKveWugkFCn4u1NCqfc629zH6/tokenclasses/JOSH"
							},
							{
								"version":100,
								"serializer":836187407,
								"addresses":[
									":adr:JHd1zCEKkXMhwz7GgSuENRrcFpPKveWugkFCn4u1NCqfc629zH6"
								]
							},
							{
								"version":100,
								"serializer":68029398,
								"owner":":byt:A8lEvWqjdjic9W0Lxe0qFXpYHK62MtDNLSa2+xaP9w0G"
							}
						],
						"name":":str:Joshy Token",
						"description":":str:The Best Coin Ever",
						"granularity":":u20:1",
						"permissions":{
							"burn":":str:token_owner_only",
							"mint":":str:token_owner_only",
							"transfer":":str:all"
						}
					},
					"spin":1
				},
				{
					"version":100,
					"serializer":-993052100,
					"particle":{
						"version":100,
						"serializer":-1820701723,
						"quarks":[
							{
								"version":100,
								"serializer":68029398,
								"owner":":byt:A8lEvWqjdjic9W0Lxe0qFXpYHK62MtDNLSa2+xaP9w0G"
							},
							{
								"version":100,
								"serializer":836187407,
								"addresses":[
									":adr:JHd1zCEKkXMhwz7GgSuENRrcFpPKveWugkFCn4u1NCqfc629zH6"
								]
							},
							{
								"version":100,
								"serializer":572705468,
								"planck":25865418,
								"nonce":1548325112815,
								"amount":":u20:10000000000000000000000",
								"type":":str:minted"
							}
						],
						"token_reference":":rri:/JHd1zCEKkXMhwz7GgSuENRrcFpPKveWugkFCn4u1NCqfc629zH6/tokenclasses/JOSH",
						"granularity":":u20:1"
					},
					"spin":1
				}
			]
		},
		{
			"version":100,
			"serializer":-67058791,
			"particles":[
				{
					"version":100,
					"serializer":-993052100,
					"particle":{
						"version":100,
						"serializer":-1611775620,
						"quarks":[
							{
								"version":100,
								"serializer":-495126317,
								"timestamps":{
									"default":1548325112801
								}
							}
						]
					},
					"spin":1
				}
			]
		},
		{
			"version":100,
			"serializer":-67058791,
			"particles":[
				{
					"version":100,
					"serializer":-993052100,
					"particle":{
						"version":100,
						"serializer":-95901716,
						"quarks":[
							{
								"version":100,
								"serializer":68029398,
								"owner":":byt:A8lEvWqjdjic9W0Lxe0qFXpYHK62MtDNLSa2+xaP9w0G"
							},
							{
								"version":100,
								"serializer":836187407,
								"addresses":[
									":adr:JHd1zCEKkXMhwz7GgSuENRrcFpPKveWugkFCn4u1NCqfc629zH6"
								]
							},
							{
								"version":100,
								"serializer":572705468,
								"planck":25865418,
								"nonce":1887866948436064,
								"amount":":u20:34991",
								"type":":str:minted"
							}
						],
						"token_reference":":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/tokenclasses/POW",
						"granularity":":u20:1",
						"service":":uid:00000000000000000000000000000001"
					},
					"spin":1
				}
			]
		}
	],
	"signatures":{
		"71c3c2fc9fee73b13cad082800a6d0de":{
			"version":100,
			"serializer":-434788200,
			"r":":byt:AJRULGkmWzxVx0AtO8NYmZ0Aqbi6hG/Vj6GeoB3TvHAX",
			"s":":byt:AKbKCyHw9GYP6EyjbyQackXtF4Hj7CgX2fmTltg5VX9H"
		}
	}
}
"""
