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

public final class DetermineIfPeerIsSuitable {
    public typealias IsPeerSuitable = (RadixNodeState, Shards) -> Bool
    private let isPeerSuitable: IsPeerSuitable
    public init(isPeerSuitable: @escaping IsPeerSuitable) {
        self.isPeerSuitable = isPeerSuitable
    }
}

public extension DetermineIfPeerIsSuitable {
    func isSuitablePeer(state: RadixNodeState, shards: Shards) -> Bool {
        isPeerSuitable(state, shards)
    }
}

public extension DetermineIfPeerIsSuitable {
    
    static func basedOn(
        ifUniverseIsSuitable isUniverseSuitable: DetermineIfUniverseIsSuitable,
        ifShardsMatchesShardSpace: DetermineIfShardSpaceMatchesShards = .default
    ) -> DetermineIfPeerIsSuitable {
        
        return DetermineIfPeerIsSuitable { nodeState, shards in
            // We WANT to retain `DetermineIfUniverseIsSuitable` and `DetermineIfShardSpaceMatchesShards`
            // here, since they are not retained elsewhere, thus we do NOT use `weak`.
            
            guard let universeConfig = nodeState.universeConfig else { return false }
            guard let shardSpace = nodeState.shardSpace else { return false }
            
            let shardMatch = ifShardsMatchesShardSpace.does(shards: shards, matchSpace: shardSpace)
            let universeMatch = isUniverseSuitable.isUniverseSuitableBasedOn(config: universeConfig)
            
            let isPeerSuitable = shardMatch && universeMatch
            return isPeerSuitable
        }
    }
}
