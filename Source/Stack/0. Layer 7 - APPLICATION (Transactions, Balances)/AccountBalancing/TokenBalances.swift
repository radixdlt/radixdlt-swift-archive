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

public struct TokenBalances: Equatable, DictionaryConvertible {
    
    public let balancePerToken: [ResourceIdentifier: TokenBalance]

    public init(dictionary: Map) {
        do {
            self.balancePerToken = try Self.validate(dictionary: dictionary)
        } catch { badLiteralValue(dictionary, error: error) }
    }

    public init(balances: [TokenBalance]) throws {
        let map = try [ResourceIdentifier: TokenBalance](balances.map { (key: $0.token.tokenDefinitionReference, value: $0) }, uniquingKeysWith: { last, new in
            throw Error.tokenBalanceArrayContainsDuplicateEntries(last: last, new: new)
            })
        self.balancePerToken = map
    }
}

public extension TokenBalances {
    @discardableResult
    static func validate(dictionary: Map) throws -> Map {
        try Self.validate(keyValuePairs: dictionary.map { ($0.key, $0.value) })
    }
    
    static func validate(keyValuePairs: [(Key, Value)]) throws -> Map {
        for (key, value) in keyValuePairs {
            let token = value.token
            guard token.tokenDefinitionReference == key else {
                throw Error.resourceIdentifierOf(token: token, doesNotMatchKey: key)
            }
        }
        // All is well
        return Map.init(uniqueKeysWithValues: keyValuePairs)
    }
    
}

public extension TokenBalances {
    enum Error: Swift.Error, Equatable {
        case resourceIdentifierOf(token: TokenDefinition, doesNotMatchKey: ResourceIdentifier)
        case mergingTokenBalancesWithDifferentOwners(last: Address, new: Address)
        case tokenBalanceArrayContainsDuplicateEntries(last: TokenBalance, new: TokenBalance)
    }
}

// MARK: DictionaryConvertible
public extension TokenBalances {
    
    typealias Key = ResourceIdentifier
    typealias Value = TokenBalance

    var dictionary: Map { balancePerToken }
}

public extension TokenBalances {
    
    static let empty = Self(dictionary: [:])
}

public extension TokenBalances {
    func balance(ofToken identifier: ResourceIdentifier) -> TokenBalance? {
        return balancePerToken[identifier]
    }
}

public extension TokenBalances {
    func merging(with new: Self) throws -> Self {
        return try self.merging(with: new, uniquingKeysWith: { last, new in
            if last.owner != new.owner {
                throw Error.mergingTokenBalancesWithDifferentOwners(last: last.owner, new: new.owner)
            }
            
            if last.token != new.token {
                print("⚠️ replacing last token definition: '\(last.token)' with new: \(new.token)")
            }
            
            if last.amount != new.amount {
                print("💡👍 replacing last amount: '\(last.amount)' with new: \(new.amount)")
            }
            return new
        })
    }
}
