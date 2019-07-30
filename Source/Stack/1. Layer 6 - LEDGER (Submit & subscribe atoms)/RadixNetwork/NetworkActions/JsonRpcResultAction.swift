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
