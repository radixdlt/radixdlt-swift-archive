//
//  JsonRpcResultAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-03.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol BaseJsonRpcResultAction: NodeAction {
    var anyResult: Any { get }
}
public protocol JsonRpcResultAction: BaseJsonRpcResultAction {
    associatedtype Result
    var result: Result { get }
}
public extension JsonRpcResultAction {
    var anyResult: Any { return result }
}

//public struct AnyJsonRpcResult<Result>: JsonRpcResultAction {
//
//    private let _getResult: () -> Result
//    private let _getNode: () -> Node
//
//    public init<Concrete>(_ concrete: Concrete) where Concrete: JsonRpcResultAction, Concrete.Result == Result {
//        self._getResult = { concrete.result }
//        self._getNode = { concrete.node }
//    }
//
//}
//
//public extension AnyJsonRpcResult {
//    var result: Result {
//        return self._getResult()
//    }
//
//    var node: Node {
//        return self._getNode()
//    }
//}
