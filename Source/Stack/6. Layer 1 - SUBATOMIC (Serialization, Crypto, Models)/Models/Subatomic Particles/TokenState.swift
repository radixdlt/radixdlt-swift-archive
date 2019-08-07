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

public struct TokenState:
    TokenConvertible,
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
    public let iconUrl: URL?
    
    private init(
        totalSupply: Supply,
        tokenSupplyType: SupplyType,
        symbol: Symbol,
        name: Name,
        tokenDefinedBy: Address,
        description: Description,
        granularity: Granularity,
        iconUrl: URL?
    ) {
        self.totalSupply = totalSupply
        self.tokenSupplyType = tokenSupplyType
        
        self.symbol = symbol
        self.name = name
        self.tokenDefinedBy = tokenDefinedBy
        self.description = description
        self.granularity = granularity
        self.iconUrl = iconUrl
    }
}

// MARK: - Convenience Initializers

internal extension TokenState {
    init(
        token tokenDefinition: TokenConvertible,
        supply: Supply
    ) {
        
        self.init(
            totalSupply: supply,
            tokenSupplyType: tokenDefinition.tokenSupplyType,
            symbol: tokenDefinition.symbol,
            name: tokenDefinition.name,
            tokenDefinedBy: tokenDefinition.tokenDefinedBy,
            description: tokenDefinition.description,
            granularity: tokenDefinition.granularity,
            iconUrl: tokenDefinition.iconUrl
        )
    }
}

// MARK: - Throwing
public extension TokenState {
    enum Error: Swift.Error, Equatable {
        case tokenDefinitionReferenceMismatch
    }
}
