//
//  TokenPermissionBadValueSpec
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class TokenPermissionBadValueTests: AtomJsonDeserializationChangeJson {
    
    func testJsonDecodingTokenDefinitionParticleBadPermissionsValue() {
        // GIVEN
        let badJson = self.replaceValueInParticle(for: .permissions, with: "{ \"burn\": \":str:foobar\"}")
        
        XCTAssertThrowsSpecificError(
            // WHEN
            // I try decoding the bad json string into an Atom
            try decode(Atom.self, jsonString: badJson),
            // THEN
            TokenPermission.Error.unsupportedPermission("foobar"),
            "Decoding should fail to deserialize JSON with a 'foobar' permission"
        )
    }
    
    func testJsonDecodingTokenDefinitionParticlePermissionsMissingMint() {
        // GIVEN
        let badJson = self.replaceValueInParticle(for: .permissions, with: "{ \"burn\": \":str:none\" }")
        
        XCTAssertThrowsSpecificError(
            // WHEN
            // I try decoding the bad json string into an Atom
            try decode(Atom.self, jsonString: badJson),
            // THEN
            TokenPermissions.Error.mintMissing,
            "Decoding should fail to deserialize JSON with permission missing mint"
        )
    }
        
    func testJsonDecodingTokenDefinitionParticlePermissionsMissingBurn() {
        // GIVEN
        let badJson = self.replaceValueInParticle(for: .permissions, with: "{ \"mint\": \":str:none\" }")
        
        XCTAssertThrowsSpecificError(
            // WHEN
            // I try decoding the bad json string into an Atom
            try decode(Atom.self, jsonString: badJson),
            // THEN
            TokenPermissions.Error.burnMissing,
            "Decoding should fail to deserialize JSON with permission missing burn"
        )
    }
}
