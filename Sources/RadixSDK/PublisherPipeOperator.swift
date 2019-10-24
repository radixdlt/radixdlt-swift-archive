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

precedencegroup Pipe {
    associativity: left
}

infix operator |>: Pipe

// swiftlint:disable opening_brace

/// Pipe Publishers together using this operator
/// Requires the use of small declared functions
/// their names should be prefixed with the name
/// of the primary `Combine` operator used.
///
/// Example:
/// ```
///    findANode(originURL: "localhost:8080")
///         |> flatMapGetUniverseConfig
///         |> filterIsInMyUniverse
///         |> filterCanServeMe
/// ```
///
/// Which is nice syntactic sugar for:
/// ```
///     findANode(originURL: "localhost:8080")
///         .flatMap { node in
///             self.getUniverseConfig(forNode: node).map { config in
///                 NodeWithConfig(node: node, config: config)
///             }
///         }.filter {
///             $0.universeConfig == self.mine
///         }.filter {
///             $0.nodeInfo.shardSpace.intersectsWithShards(self.myShard)
///         }.eraseToAnyPublisher()
/// ```
///
/// In the sweet example using this operator above, of course we have to
/// declare all the functions, like so:
/// ```
///    func flatMapGetUniverseConfig<P>(_ publisher: P) -> AnyPublisher<NodeWithConfig, Never>
///         where P: Publisher, P.Output == InfoForNode, P.Failure == Never {
///
///        publisher.flatMap { infoForNode in
///            self.universeConfigOfNode(node: infoForNode.node).map { universeConfigOfNode in
///                NodeWithConfig(InfoForNode: infoForNode, universeConfig: universeConfigOfNode)
///            }
///        }
///        .eraseToAnyPublisher()
///    }
///
///    func filterIsInMyUniverse<P>(_ publisher: P) -> AnyPublisher<NodeWithConfig, Never>
///        where P: Publisher, P.Output == NodeWithConfig, P.Failure == Never
///    {
///        publisher.filter { $0.universeConfig == self.mine }
///            .eraseToAnyPublisher()
///    }
///
///    func filterCanServeMe<P>(_ publisher: P) -> AnyPublisher<NodeWithConfig, Never>
///        where P: Publisher, P.Output == NodeWithConfig, P.Failure == Never
///    {
///        publisher.filter { $0.nodeInfo.shardSpace.intersectsWithShards(self.myShard) ///   }.eraseToAnyPublisher()
///    }
///
/// ```
///
/// But the nice thing about this divide and conquer technique is that we can write test for each
/// function!
///
internal func |><Upstream, Downstream, Output, Failure>(
    upstream: Upstream,
    stream: (Upstream) -> Downstream
) -> AnyPublisher<Output, Failure>
    where
    Upstream: Publisher,
    Downstream: Publisher,
    Upstream.Failure == Failure,
    Downstream.Failure == Upstream.Failure,
    Output == Downstream.Output
{
    stream(upstream).eraseToAnyPublisher()
}

// swiftlint:enable opening_brace
