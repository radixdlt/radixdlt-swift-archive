//
//  TokenPermissionBadValueSpec
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class TokenPermissionBadValueSpec: AtomJsonDeserializationChangeJson {
    
    override func spec() {
        /// Scenario 11
        /// https://radixdlt.atlassian.net/browse/RLAU-567
        describe("JSON deserialization - TokenDefinitionParticle: Bad permission value") {
            let badJson = self.replaceValueInParticle(for: .permissions, with: "{ \"burn\": \":str:foobar\"}")
            it("should fail to deserialize JSON with a foobar permission") {
                expect { try decode(Atom.self, from: badJson) }.to(throwError(errorType: TokenPermission.Error.self) {
                    switch $0 {
                    case .unsupportedPermission(let name):
                        expect(name).to(equal("foobar"))
                    }
                })
            }
        }
        
        /// Scenario Extra
        describe("JSON deserialization - TokenDefinitionParticle: Lacking permission") {
            it("Deserialize JSON with lacking TokenPermission for action 'mint' should throw error 'mintMissing'") {
                let badJson = self.replaceValueInParticle(for: .permissions, with: "{ \"burn\": \":str:none\" }")
                expect { try decode(Atom.self, from: badJson) }.to(throwError(TokenPermissions.Error.mintMissing))
            }
            
            it("Deserialize JSON with lacking TokenPermission for action 'mint' should throw error 'burnMissing'") {
                let badJson = self.replaceValueInParticle(for: .permissions, with: "{ \"mint\": \":str:none\" }")
                expect { try decode(Atom.self, from: badJson) }.to(throwError(TokenPermissions.Error.burnMissing))
            }
        }
    }
}
