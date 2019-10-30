//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

public protocol RadixNetwork {
    var state: RadixNetworkState { get }
    func reduce(state: RadixNetworkState, action: NodeAction) -> RadixNetworkState
}

public final class DefaultRadixNetwork: RadixNetwork {
    public private(set) var state: RadixNetworkState
    
    public init(state: RadixNetworkState = .init()) {
        self.state = state
    }
}

public extension DefaultRadixNetwork {
    
    func reduce(state: RadixNetworkState, action nodeAction: NodeAction) -> RadixNetworkState {
        guard let action = nodeAction as? RadixNetworkNodeAction else { return state }
        let node = action.node
        log.verbose("Reducing network, action: \(action), from state: \(state.debugDescription)")
        
        if let nodeInfoResult = action as? GetNodeInfoActionResult {
            return state.insertingMergeIfNeeded(for: node, nodeInfo: nodeInfoResult.result)
        } else if let universeConfigResult = action as? GetUniverseConfigActionResult {
            return state.insertingMergeIfNeeded(for: node, universeConfig: universeConfigResult.result)
        } else if let addNodeAction = action as? AddNodeAction {
            return state.insertingMergeIfNeeded(for: node, webSocketStatusValue: .new(.disconnected), nodeInfo: addNodeAction.nodeInfo)
        } else if let webSocketEvent = action as? WebSocketEvent {
            return state.insertingMergeIfNeeded(for: node, webSocketStatusValue: .new(webSocketEvent.webSocketStatus))
        } else {
            fatalError("missed something?")
        }
        
    }
}

internal enum ExistingOrNewValue<Value> {
    case existingElseCrash
    case new(Value)
}

extension ExistingOrNewValue {
    func getValue(existing: Value?) -> Value {
        switch self {
        case .existingElseCrash:
            guard let indeedExisting = existing else {
                incorrectImplementation("Bad logic")
            }
            return indeedExisting
        case .new(let new): return new
        }
    }
}
