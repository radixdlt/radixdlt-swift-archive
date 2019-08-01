//
//  NodeInfoRequesting.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol NodeNetworkInfoRequesting {
    func getNetworkInfo() -> Single<RadixSystem>
}

public protocol NodeInfoRequesting {
    func getInfo() -> Single<NodeInfo>
}

public extension NodeInfoRequesting where Self: NodeNetworkInfoRequesting {
    func getInfo() -> Single<NodeInfo> {
        return getNetworkInfo().map { NodeInfo(system: $0, host: nil) }
    }
}

