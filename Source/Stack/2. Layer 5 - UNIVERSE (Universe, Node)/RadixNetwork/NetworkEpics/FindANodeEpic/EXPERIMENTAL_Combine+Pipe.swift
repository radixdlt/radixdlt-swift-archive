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
import Combine

struct InfoForNode: Equatable {
    let nodeInfo: NodeInfo
    let node: Node
}

struct NodeWithConfig: Equatable {
    let infoForNode: InfoForNode
    let universeConfig: UniverseConfig
}
extension NodeWithConfig {
    var nodeInfo: NodeInfo { infoForNode.nodeInfo }
    var node: Node { infoForNode.node }
}

public typealias Pipe<Output, Failure> = (AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> where Failure: Swift.Error

public typealias PipeNodeAction<Failure> = Pipe<NodeAction, Failure> where Failure: Swift.Error

// TODO: replace `Never` with `FindANodeError`
public typealias PipeFindANodeEpicActions = PipeNodeAction<Never>


private enum Foo {
    var mine: UniverseConfig { abstract() }
    var myAddress: Address { abstract() }
    var myShard: Shards { .init(single: myAddress.shard) }
    
    func findANode(originURL: URL) -> AnyPublisher<InfoForNode, Never> {
        implementMe()
    }
    
    func universeConfig(of node: Node) -> AnyPublisher<UniverseConfig, Never> {
        abstract()
    }
    
    func flatMapGetUniverseConfig<P>(_ publisher: P) -> AnyPublisher<NodeWithConfig, Never> where P: Publisher, P.Output == InfoForNode, P.Failure == Never {
        
        publisher.flatMap { infoForNode in
            self.universeConfig(of: infoForNode.node).map { universeConfigOfNode in
                NodeWithConfig(infoForNode: infoForNode, universeConfig: universeConfigOfNode)
            }
        }
        .eraseToAnyPublisher()
    }
    
    func filterIsInMyUniverse<P>(_ publisher: P) -> AnyPublisher<NodeWithConfig, Never> where P: Publisher, P.Output == NodeWithConfig, P.Failure == Never {
        publisher.filter { $0.universeConfig == self.mine }
            .eraseToAnyPublisher()
    }
    
    func filterCanServeMe<P>(_ publisher: P) -> AnyPublisher<NodeWithConfig, Never> where P: Publisher, P.Output == NodeWithConfig, P.Failure == Never {
        publisher.filter { $0.nodeInfo.shardSpace.intersectsWithShards(self.myShard) }.eraseToAnyPublisher()
    }
    
    func findSuitableNode() -> AnyPublisher<NodeWithConfig, Never> {
        findANode(originURL: "localhost:8080")
            |> flatMapGetUniverseConfig
            |> filterIsInMyUniverse
            |> filterCanServeMe
    }
    
}

