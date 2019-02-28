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
                do {
                    try decode(Atom.self, from: badJson)
                    fail("Should not be able to decode invalid JSON")
                } catch let error as TokenPermission.Error {
                    if case .unsupportedPermission(let name) = error {
                        expect(name).to(equal("foobar"))
                    } else {
                        fail("wrong error")
                    }
                } catch {
                    fail("Wrong error type, got: \(error)")
                }
            }
        }
        
        /// Scenario Extra
        describe("JSON deserialization - TokenDefinitionParticle: Lacking permission") {
            it("Deserialize JSON with lacking TokenPermission for action 'transfer' should throw error 'transferMissing'") {
                let badJson = self.replaceValueInParticle(for: .permissions, with: "{ \"burn\": \":str:pow\", \"mint\": \":str:pow\"}")
                expect { try decode(Atom.self, from: badJson) }.to(throwError(TokenPermissions.Error.transferMissing))
            }
            
            it("Deserialize JSON with lacking TokenPermission for action 'mint' should throw error 'mintMissing'") {
                let badJson = self.replaceValueInParticle(for: .permissions, with: "{ \"burn\": \":str:pow\", \"transfer\": \":str:pow\"}")
                expect { try decode(Atom.self, from: badJson) }.to(throwError(TokenPermissions.Error.mintMissing))
            }
            
            it("Deserialize JSON with lacking TokenPermission for action 'mint' should throw error 'burnMissing'") {
                let badJson = self.replaceValueInParticle(for: .permissions, with: "{ \"mint\": \":str:pow\", \"transfer\": \":str:pow\"}")
                expect { try decode(Atom.self, from: badJson) }.to(throwError(TokenPermissions.Error.burnMissing))
            }
        }
    }
}
