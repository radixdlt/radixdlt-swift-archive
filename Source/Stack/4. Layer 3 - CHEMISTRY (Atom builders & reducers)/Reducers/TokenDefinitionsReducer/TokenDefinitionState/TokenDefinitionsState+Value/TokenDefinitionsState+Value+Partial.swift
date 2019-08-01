/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import Foundation

public extension TokenDefinitionsState.Value {
    enum Partial: TokenDefinitionReferencing, Equatable {
        case supply(TokenDefinitionsState.SupplyInfo)
        case tokenDefinition(TokenDefinition)
    }
}

// MARK: - TokenDefinitionReferencing
public extension TokenDefinitionsState.Value.Partial {
    var tokenDefinitionReference: ResourceIdentifier {
        switch self {
        case .supply(let supplyState): return supplyState.tokenDefinitionReference
        case .tokenDefinition(let tokenDefintion): return tokenDefintion.tokenDefinitionReference
        }
    }
}

// MARK: - Internal
internal extension TokenDefinitionsState.Value.Partial {
    func merging(with newPartial: TokenDefinitionsState.Value.Partial) throws -> TokenDefinitionsState.Value {
        guard self.tokenDefinitionReference == newPartial.tokenDefinitionReference else {
            throw TokenDefinitionsState.Error.tokenDefinitionReferenceMismatch
        }
        
        switch (self, newPartial) {
        case (.tokenDefinition(let currentTokenDefinition), .supply(let newSupplyInfo)):
            return .full(
                try TokenState(
                    token: currentTokenDefinition,
                    supplyState: newSupplyInfo
                )
            )
            
        case (.supply(let currentSupplyInfo), .tokenDefinition(let newTokenDefinition)):
            return .full(
                try TokenState(
                    token: newTokenDefinition,
                    supplyState: currentSupplyInfo
                )
            )
            
        case (.supply(let currentSupplyInfo), .supply(let newSupplyInfo)):
            let accumulatedSupply = try currentSupplyInfo.totalSupply.add(newSupplyInfo.totalSupply)
            
            let accumulatedSupplyInfo = TokenDefinitionsState.SupplyInfo(
                totalSupply: accumulatedSupply,
                tokenDefinitionReference: tokenDefinitionReference
            )
            
            return .partial(.supply(accumulatedSupplyInfo))
            
        case (.tokenDefinition, .tokenDefinition(let newTokenDefinition)):
            return .partial(.tokenDefinition(newTokenDefinition))
        }
    }
}
