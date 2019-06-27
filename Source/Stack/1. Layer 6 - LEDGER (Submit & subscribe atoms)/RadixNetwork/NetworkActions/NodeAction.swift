//
//  NodeAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol NodeAction {
    var node: Node? { get }
}

public extension NodeAction {
    var node: Node? { return nil }
}

//public protocol FindANodeRequestAction: NodeAction {
//    func shards() throws -> Shards
//}
//
//public protocol FetchAtomsAction: NodeAction {
//    var uuid: UUID { get }
//    var address: Address { get }
//}
//
//public struct FetchAtomsRequestAction: FindANodeRequestAction, FetchAtomsAction {
//    public let address: Address
//    public let uuid: UUID
//    public init(address: Address, uuid: UUID = .init()) {
//        self.address = address
//        self.uuid = uuid
//    }
//}
//public extension FetchAtomsRequestAction {
//    func shards() throws -> Shards {
//        return Shards(single: address.publicKey.shard)
//    }
//}
//
//public struct FetchAtomsCancelAction: FetchAtomsAction {
//    public let address: Address
//    public let uuid: UUID
//    public init(address: Address, uuid: UUID) {
//        self.address = address
//        self.uuid = uuid
//    }
//}
