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

public typealias TokenStateConvertible = TokenConvertible & TokenSupplyStateConvertible

// swiftlint:disable colon opening_brace

public struct TokenState:
    TokenStateConvertible,
    Throwing,
    Hashable
{
    // swiftlint:enable colon opening_brace
    
    // MARK: - Properties
    public let totalSupply: Supply
    public let tokenSupplyType: SupplyType
    
    // MARK: TokenConvertible Properties
    public let symbol: Symbol
    public let name: Name
    public let tokenDefinedBy: Address
    public let description: Description
    public let granularity: Granularity
    
    private init(
        totalSupply: Supply,
        tokenSupplyType: SupplyType,
        symbol: Symbol,
        name: Name,
        tokenDefinedBy: Address,
        description: Description,
        granularity: Granularity
    ) {
        self.totalSupply = totalSupply
        self.tokenSupplyType = tokenSupplyType
        
        self.symbol = symbol
        self.name = name
        self.tokenDefinedBy = tokenDefinedBy
        self.description = description
        self.granularity = granularity
    }
}

// MARK: - Convenience Initializers

// MARK: Private Init
private extension TokenState {
    init(
        token tokenDefinition: TokenConvertible,
        totalSupply: Supply
    ) {
        
        self.init(
            totalSupply: totalSupply,
            tokenSupplyType: tokenDefinition.tokenSupplyType,
            symbol: tokenDefinition.symbol,
            name: tokenDefinition.name,
            tokenDefinedBy: tokenDefinition.tokenDefinedBy,
            description: tokenDefinition.description,
            granularity: tokenDefinition.granularity
        )
    }
}

// MARK: Public Init
public extension TokenState {

    init(
        token tokenDefinition: TokenConvertible,
        supplyState: TokenSupplyStateConvertible
    ) throws {
        
        guard tokenDefinition.tokenDefinitionReference == supplyState.tokenDefinitionReference else {
            throw Error.tokenDefinitionReferenceMismatch
        }
        self.init(
            token: tokenDefinition,
            totalSupply: supplyState.totalSupply
        )
    }
    
    init(tokenStateConvertible: TokenStateConvertible) {
        self.init(
            token: tokenStateConvertible,
            totalSupply: tokenStateConvertible.totalSupply
        )
    }
}

// MARK: - Throwing
public extension TokenState {
    enum Error: Swift.Error, Equatable {
        case tokenDefinitionReferenceMismatch
    }
}

// MARK: - Merge
public extension TokenState {
    func merging(with other: TokenState) throws -> TokenState {

        if other.tokenDefinitionReference != tokenDefinitionReference {
            throw Error.tokenDefinitionReferenceMismatch
        }

        let updatedTotalSupply = try self.totalSupply.add(other.totalSupply)

        return TokenState(
            token: other,
            totalSupply: updatedTotalSupply
        )
    }

    func mergingWithPartial(_ partial: TokenDefinitionsState.Value.Partial) throws -> TokenState {
        guard partial.tokenDefinitionReference == self.tokenDefinitionReference else {
            throw Error.tokenDefinitionReferenceMismatch
        }
        
        switch partial {
        case .supply(let supplyInfo):
            return try TokenState(token: self, supplyState: supplyInfo)
        case .tokenDefinition(let tokenDefinition):
            return TokenState(
                token: tokenDefinition,
                totalSupply: self.totalSupply
            )
        }
    }
}
