//
//  FetchAtomsAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol FetchAtomsAction: NodeAction {
    var address: Address { get }
    var uuid: UUID { get }
}

public struct FetchAtomsActionCancel: FetchAtomsAction {
    public let address: Address
    public let uuid: UUID
    private init(address: Address, uuid: UUID = .init()) {
        self.address = address
        self.uuid = uuid
    }
    public init(request: FetchAtomsActionRequest) {
        self.init(address: request.address, uuid: request.uuid)
    }
}

public struct FetchAtomsActionObservation: FetchAtomsAction {
    public let address: Address
    public let node: Node
    public let atomObservation: AtomObservation
    public let uuid: UUID
}

public struct FetchAtomsActionRequest: FetchAtomsAction, FindANodeRequestAction {
    public let address: Address
    public let uuid: UUID
    
    public init(address: Address, uuid: UUID = .init()) {
        self.address = address
        self.uuid = uuid
    }
    
    public var shards: Shards {
        return Shards(single: address.shard)
    }
}

public struct FetchAtomsActionSubscribe: FetchAtomsAction {
    public let address: Address
    public let node: Node
    public let uuid: UUID
}
