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

// swiftlint:disable colon opening_brace

/// In Java library called `NodeRunnerData`
public struct NodeInfo:
    RadixModelTypeStaticSpecifying,
    Decodable,
    Hashable
{
    // swiftlint:enable colon opening_brace
    
    public let system: RadixSystem
    public let host: Host?
    
    public init(system: RadixSystem, host: Host?) {
        self.system = system
        self.host = host
    }
}

// MARK: - Equatable
public extension NodeInfo {
    func hash(into hasher: inout Hasher) {
        if let host = host {
            hasher.combine(host.domain)
        }
        hasher.combine(system.shardSpace)
    }
}

// MARK: - Equatable
public extension NodeInfo {
    static func == (lhs: NodeInfo, rhs: NodeInfo) -> Bool {
        guard lhs.system.shardSpace == rhs.system.shardSpace else { return false }
        
        let maybeLhsHost = lhs.host
        let maybeRhsHost = rhs.host
        switch (maybeLhsHost, maybeRhsHost) {
        case (.some(let lhsHost), .some(let rhsHost)): return lhsHost == rhsHost
        case (.none, .none): return true
        default: return false
        }
    }
}

public extension NodeInfo {
    var shardSpace: ShardSpace {
        return system.shardSpace
    }
}

// MARK: - Decodable
public extension NodeInfo {
    
    enum CodingKeys: String, CodingKey {
        case host
        case system
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.host = try container.decode(Host.self, forKey: .host)
        self.system = try container.decode(RadixSystem.self, forKey: .system)
    }
}

// MARK: - RadixModelTypeStaticSpecifying
public extension NodeInfo {
    static let serializer: RadixModelType = .nodeInfo
}
