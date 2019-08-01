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

public struct CreateTokenAction: UserAction, Throwing, TokenConvertible, TokenSupplyStateConvertible {

    public let creator: Address
    public let name: Name
    public let symbol: Symbol
    public let description: Description
    public let granularity: Granularity
    public let initialSupply: Supply
    public let tokenSupplyType: SupplyType
    public let iconUrl: URL?
    
    public init(
        creator: Address,
        name: Name,
        symbol: Symbol,
        description: Description,
        supply initialSupplyType: InitialSupply,
        granularity: Granularity = .default,
        iconUrl: URL? = nil
    ) throws {

        switch initialSupplyType {
        case .fixed(let positiveInitialSupply):
            self.tokenSupplyType = .fixed
            self.initialSupply = positiveInitialSupply
        case .mutable(let nonNegativeInitialSupply):
            self.tokenSupplyType = .mutable
            self.initialSupply = nonNegativeInitialSupply ?? .zero
        }
        
        guard initialSupply.isExactMultipleOfGranularity(granularity) else {
            throw Error.initialSupplyNotMultipleOfGranularity
        }
        
        self.creator = creator
        self.name = name
        self.symbol = symbol
        self.description = description
        self.granularity = granularity
        self.iconUrl = iconUrl
    }
}

public extension CreateTokenAction {
    var nameOfAction: UserActionName { return .createToken }
}

// MARK: - Throwing
public extension CreateTokenAction {
    enum Error: Swift.Error, Equatable {
        case initialSupplyNotMultipleOfGranularity
    }
}

// MARK: - TokenConvertible
public extension CreateTokenAction {
    var tokenDefinedBy: Address {
        return creator
    }
}

// MARK: - TokenSupplyStateConvertible
public extension CreateTokenAction {
    var totalSupply: Supply {
        return initialSupply
    }
}

public extension CreateTokenAction {
    var identifier: ResourceIdentifier {
        return ResourceIdentifier(address: creator, symbol: symbol)
    }
}

public extension CreateTokenAction {
    
    enum InitialSupply {
        case fixed(to: Supply)
        case mutable(initial: Supply?)
    }
}
