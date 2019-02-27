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
        describe("JSON deserialization - TokenDefinitionParticle: Bad permissions") {
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
    }
}
