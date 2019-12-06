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
@testable import RadixSDK

extension RadixApplicationClient {
    static var localhostAliceSingleNodeApp: RadixApplicationClient {
        return RadixApplicationClient(bootstrapConfig: UniverseBootstrap.default, identity: AbstractIdentity())
    }
    
    func createToken(
        creator: Address? = nil,
        name: Name = .irrelevant,
        symbol: Symbol = .random,
        description: Description = .irrelevant,
        supply supplyTypeDefinition: CreateTokenAction.InitialSupply.SupplyTypeDefinition = .mutableZeroSupply,
        iconUrl: URL? = nil,
        granularity: Granularity = .default
    ) -> (result: PendingTransaction, rri: ResourceIdentifier) {
        
        let createTokenAction = try! CreateTokenAction(
            creator: creator ?? addressOfActiveAccount,
            name: name,
            symbol: symbol,
            description: description,
            supply: supplyTypeDefinition,
            iconUrl: iconUrl,
            granularity: granularity
        )
        
        return (createToken(action: createTokenAction), createTokenAction.identifier)
    }
    
    func createFixedSupplyToken(
        creator: Address? = nil,
        name: Name = .irrelevant,
        symbol: Symbol = .random,
        description: Description = .irrelevant,
        iconUrl: URL? = nil,
        supply: PositiveSupply = .max,
        granularity: Granularity = .default
        ) -> (result: PendingTransaction, rri: ResourceIdentifier) {
        
        return try! createToken(
            creator: creator ?? addressOfActiveAccount,
            name: name,
            symbol: symbol,
            description: description,
            supply: .fixed(to: supply),
            iconUrl: iconUrl,
            granularity: granularity
        )
    }
    
    func createMultiIssuanceToken(
        creator: Address? = nil,
        name: Name = .irrelevant,
        symbol: Symbol = .random,
        description: Description = .irrelevant,
        iconUrl: URL? = nil,
        initialSupply: Supply? = nil,
        granularity: Granularity = .default
    ) -> (result: PendingTransaction, rri: ResourceIdentifier) {
        
        return try! createToken(
            creator: creator ?? addressOfActiveAccount,
            name: name,
            symbol: symbol,
            description: description,
            supply: .mutable(initial: initialSupply),
            iconUrl: iconUrl,
            granularity: granularity
        )
    }
}

// ACTION
extension RadixApplicationClient {
    
    func actionCreateToken(
        creator: Address? = nil,
        name: Name = .irrelevant,
        symbol: Symbol = .random,
        description: Description = .irrelevant,
        iconUrl: URL? = nil,
        supply: CreateTokenAction.InitialSupply.SupplyTypeDefinition = .mutableZeroSupply,
        granularity: Granularity = .default
    ) -> CreateTokenAction {
        
        return try! CreateTokenAction(
            creator: creator ?? addressOfActiveAccount,
            name: name,
            symbol: symbol,
            description: description,
            supply: supply,
            iconUrl: iconUrl,
            granularity: granularity
        )
    }
    
    func actionCreateFixedSupplyToken(
        creator: Address? = nil,
        name: Name = .irrelevant,
        symbol: Symbol = .random,
        description: Description = .irrelevant,
        iconUrl: URL? = nil,
        supply: PositiveSupply = .max,
        granularity: Granularity = .default
    ) -> CreateTokenAction {
        
        return try! CreateTokenAction(
            creator: creator ?? addressOfActiveAccount,
            name: name,
            symbol: symbol,
            description: description,
            supply: .fixed(to: supply),
            iconUrl: iconUrl,
            granularity: granularity
        )
    }
    
    func actionCreateMultiIssuanceToken(
        creator: Address? = nil,
        name: Name = .irrelevant,
        symbol: Symbol = .random,
        description: Description = .irrelevant,
        initialSupply: Supply? = nil,
        iconUrl: URL? = nil,
        granularity: Granularity = .default
    ) -> CreateTokenAction {
        
        return try! CreateTokenAction(
            creator: creator ?? addressOfActiveAccount,
            name: name,
            symbol: symbol,
            description: description,
            supply: .mutable(initial: initialSupply),
            iconUrl: iconUrl,
            granularity: granularity
        )
    }
}
