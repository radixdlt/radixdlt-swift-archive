//
//  MockedNetworkDetailsRequester.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import RxSwift

//struct MockedNetworkDetailsRequester: NodeNetworkDetailsRequesting {
//    private let single: Single<NodeNetworkDetails>
//    init(_ single: Single<NodeNetworkDetails>) {
//        self.single = single
//    }
//    init(subject: PublishSubject<NodeNetworkDetails>) {
//        self.init(subject.asObservable())
//    }
//    func networkDetails() -> Single<NodeNetworkDetails> {
//        return single
//    }
//}
