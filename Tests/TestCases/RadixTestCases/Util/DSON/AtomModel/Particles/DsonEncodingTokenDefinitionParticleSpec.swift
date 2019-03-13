//
//  DsonEncodingTokenDefinitionParticleSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-13.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import Nimble
import Quick

class DsonEncodingTokenDefinitionParticleSpec: QuickSpec {
    
    override func spec() {
        describe("DSON encoding") {
            describe("TokenDefinitionParticle") {
                it("should result in the appropriate data") {
                    
                    let tokenDefinitionParticle = TokenDefinitionParticle(
                        symbol: "CYON",
                        name: "Cyon Coin",
                        description: "Worst shit coin ever",
                        address: "JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei",
                        granularity: 1
                    )
   
                    let dson = tokenDefinitionParticle.toDSON()
                expect(dson.hex).to(equal("bf67616464726573735827040203ca6219a27befbb3eb1bca0129d548489bbecca8b03bb07a30adfdff479503bfe525d04576b6465736372697074696f6e74576f727374207368697420636f696e20657665726b6772616e756c61726974795821050000000000000000000000000000000000000000000000000000000000000001646e616d656943796f6e20436f696e6b7065726d697373696f6e73bf646275726e63616c6c646d696e7463616c6c687472616e7366657263616c6cff6a73657269616c697a65723a3da8015a6673796d626f6c6443594f4e6776657273696f6e1864ff"))
                    
                    expect(dson.base64).to(equal("v2dhZGRyZXNzWCcEAgPKYhmie++7PrG8oBKdVISJu+zKiwO7B6MK39/0eVA7/lJdBFdrZGVzY3JpcHRpb250V29yc3Qgc2hpdCBjb2luIGV2ZXJrZ3JhbnVsYXJpdHlYIQUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWRuYW1laUN5b24gQ29pbmtwZXJtaXNzaW9uc79kYnVybmNhbGxkbWludGNhbGxodHJhbnNmZXJjYWxs/2pzZXJpYWxpemVyOj2oAVpmc3ltYm9sZENZT05ndmVyc2lvbhhk/w=="))
                }
            }
        }
    }
}
