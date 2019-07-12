//
//  BalanceOfNativeTokenFromGenesisAtomsTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-07-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import XCTest
@testable import RadixSDK
import RxSwift

class BalanceOfNativeTokenFromGenesisAtomsTests: XCTestCase {
    
    func testFetchAtomsAtGenesisAddress() {
        let disposeBag = DisposeBag()
        let application = RadixApplicationClient(bootstrapConfig: UniverseBootstrap.localhostSingleNode, identity: AbstractIdentity())
        let address: Address = "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor"
        application.pull(address: address).disposed(by: disposeBag)
        guard let xrdBalance = application.balanceOfNativeTokensOrZero(for: address).blockingTakeFirst(timeout: 4) else { return }
        XCTAssertEqual(xrdBalance.amount, 12345)
    }

}
