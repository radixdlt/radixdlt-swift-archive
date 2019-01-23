//
//  DsonTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import XCTest
@testable import RadixSDK

class DsonTests: XCTestCase {

    func testDecodeUniverseConfig() {
        let data = Data(base64Encoded: base64Encoded)!
        let config = try! DSONDecoder().decode(data: data, to: UniverseConfig.self)
        XCTAssertEqual(config.magic, 63799298)
        XCTAssertEqual(config.genesis.count, 3)
    }


}

private let base64Encoded = "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emVyGgAe0VFqc2lnbmF0dXJlc794IDU2YWJhYjM4NzA1ODVmMDRkMDE1ZDU1YWRmNjAwYmM3v2FyWCIBAL+KRBvEvkjLcmVE6KYiufwq1loXkqNaln4JUPB6WfHbYXNYIgEA68qLd6db8Ap1j9hCYRH8S73DTno5miXL6GFayvGOwt9qc2VyaWFsaXplcjoZ6ldnZ3ZlcnNpb24YZP//Z3ZlcnNpb24YZP+/ZmFjdGlvbmVTVE9SRW5jaHJvbm9QYXJ0aWNsZb9qc2VyaWFsaXplchpAYNIpanRpbWVzdGFtcHOhZ2RlZmF1bHQbAAABWocqmABndmVyc2lvbhhk/2tjb25zdW1hYmxlc4G/aGFzc2V0X2lkUQLXvTS/5EoY0qp1WjRP4+awbGRlc3RpbmF0aW9uc4FRAlarqzhwWF8E0BXVWt9gC8dlbm9uY2UbAAFfFbg592dmb3duZXJzgb9mcHVibGljWCIBA3hanCWf3pmR5E+i+wtWWfKleBrDOQduLb/vcFKOSt9oanNlcmlhbGl6ZXIaIJ3vO2d2ZXJzaW9uGGT/aHF1YW50aXR5GwAAWvMQekAAanNlcmlhbGl6ZXIaajslh2d2ZXJzaW9uGGT/bWRhdGFQYXJ0aWNsZXOBv2VieXRlc1YBUmFkaXguLi4uSnVzdCBJbWFnaW5lanNlcmlhbGl6ZXIaHDz8MGd2ZXJzaW9uGGT/bGRlc3RpbmF0aW9uc4FRAlarqzhwWF8E0BXVWt9gC8dqc2VyaWFsaXplchoAHtFRanNpZ25hdHVyZXO/eCA1NmFiYWIzODcwNTg1ZjA0ZDAxNWQ1NWFkZjYwMGJjN79hclghAS5Hqy7Y+E7XM6JqX4EGEIAS94dK/WEgLIbcgWX71oCzYXNYIgEAgetgaammCWF2y5vWNT+aoZOREOWeG4Q9sMBDvzIv4DJqc2VyaWFsaXplcjoZ6ldnZ3ZlcnNpb24YZP//bnRlbXBvcmFsX3Byb29mv2dhdG9tX2lkUQIEU57MLExqDgRgxG7kXU1ranNlcmlhbGl6ZXIacY6fQmd2ZXJzaW9uGGRodmVydGljZXOBv2VjbG9jawBqY29tbWl0bWVudFghAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAZW93bmVyv2ZwdWJsaWNYIgECIOL2ztjYQ4hLsm3tYnT0p6ak8wgjeFvcd4FX8xoD+qZqc2VyaWFsaXplchogne87Z3ZlcnNpb24YZP9ocHJldmlvdXNRAgAAAAAAAAAAAAAAAAAAAABqc2VyaWFsaXplcjo2M2S5aXNpZ25hdHVyZb9hclgiAQCfa+hWoKvzrOR0hqtHkLYe1m29CNU2PZNdXybFILp402FzWCIBAPm/pFs8+tSoqXF7IleP6l53RvhulqKyfmP55z/mNB8hanNlcmlhbGl6ZXI6GepXZ2d2ZXJzaW9uGGT/anRpbWVzdGFtcHOhZ2RlZmF1bHQbAAABZk87HdtndmVyc2lvbhhk//9ndmVyc2lvbhhk/2VtYWdpYxoDzYACZG5hbWVsUmFkaXggRGV2bmV0ZHBvcnQZdTBqc2VyaWFsaXplchodWDpFa3NpZ25hdHVyZS5yWCIBAI8ljsnkTqJVdUwMR76m2ehWIxaeCEZqcVCVR3Qe9QH2a3NpZ25hdHVyZS5zWCIBAIAHfvylFm7W1VTIGdY1Imly9buKNsIi7s60ZgoPYI46aXRpbWVzdGFtcBsAAAFahyqYAGR0eXBlAmd2ZXJzaW9uGGT/"
