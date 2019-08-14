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

public struct CreateTokenAction: UniquelyIdentifiedUserAction, Throwing, TokenConvertible {

    public let creator: Address
    public let name: Name
    public let symbol: Symbol
    public let description: Description
    public let granularity: Granularity
    public let iconUrl: URL?

    // Private since it is not used directly. Instead given the context either `supplyDefinition` should be used
    // for `CreateTokenActionToParticleGroupsMapper`
    private let initialSupplyContext: InitialSupply
    
    public init(
        creator: Address,
        name: Name,
        symbol: Symbol,
        description: Description,
        supply supplyTypeDefinition: InitialSupply.SupplyTypeDefinition,
        granularity: Granularity = .default,
        iconUrl: URL? = nil
    ) throws {

        try supplyTypeDefinition.isExactMultipleOfGranularity(granularity)
        
        self.creator = creator
        self.name = name
        self.symbol = symbol
        self.description = description
        self.granularity = granularity
        self.iconUrl = iconUrl
        self.initialSupplyContext = .defined(in: supplyTypeDefinition)
    }
}

// MARK: Internal
internal extension CreateTokenAction {
    init(
        creator: Address,
        name: Name,
        symbol: Symbol,
        description: Description,
        derivedSupply: InitialSupply.DerivedFromAtom,
        granularity: Granularity = .default,
        iconUrl: URL? = nil
    ) {
        self.creator = creator
        self.name = name
        self.symbol = symbol
        self.description = description
        self.granularity = granularity
        self.iconUrl = iconUrl
        self.initialSupplyContext = .derivedFromAtom(derivedSupply)
    }
}

internal extension CreateTokenAction {
    var supplyDefinition: InitialSupply.SupplyTypeDefinition? {
        switch initialSupplyContext {
        case .defined(let definition): return definition
        case .derivedFromAtom: return nil
        }
    }
}

// MARK: Public

// MARK: UserAction
public extension CreateTokenAction {
    var user: Address { return creator }
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
    var tokenSupplyType: SupplyType {
        switch initialSupplyContext {
        case .defined(let definition): return definition.tokenSupplyType
        case .derivedFromAtom(let derived):
            switch derived {
            case .fixedInitialSupply: return .fixed
            case .mutableSupply: return .mutable
            }
        }
    }
}

public extension CreateTokenAction {
    var identifier: ResourceIdentifier {
        return ResourceIdentifier(address: creator, symbol: symbol)
    }
}
