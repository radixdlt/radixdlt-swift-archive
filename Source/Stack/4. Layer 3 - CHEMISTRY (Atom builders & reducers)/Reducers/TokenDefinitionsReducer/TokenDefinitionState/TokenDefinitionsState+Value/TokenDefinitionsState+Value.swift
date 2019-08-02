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

public extension TokenDefinitionsState {
    enum Value: TokenDefinitionReferencing, Equatable {
        case partial(Partial)
        case full(TokenState)
    }
}

// MARK: - Convenience Init
public extension TokenDefinitionsState.Value {
    
    init(tokenConvertible: TokenConvertible) {
        self = .partial(.tokenDefinition(TokenDefinition(tokenConvertible: tokenConvertible)))
    }
    
    init(supplyState: TokenSupplyStateConvertible) {
        self = .partial(.supply(TokenDefinitionsState.SupplyInfo(tokenSupplyStateConvertible: supplyState)))
    }
    
    init(unallocatedTokensParticle: UnallocatedTokensParticle) {
        self = .partial(.supply(TokenDefinitionsState.SupplyInfo(unallocatedTokensParticle: unallocatedTokensParticle)))
    }
}

// MARK: - TokenDefinitionReferencing
public extension TokenDefinitionsState.Value {
    var tokenDefinitionReference: ResourceIdentifier {
        switch self {
        case .full(let tokenState): return tokenState.tokenDefinitionReference
        case .partial(let partial): return partial.tokenDefinitionReference
        }
    }
}

// MARK: - Merge
public extension TokenDefinitionsState.Value {
    
    func merging(with other: TokenDefinitionsState.Value) throws -> TokenDefinitionsState.Value {
        switch (self, other) {
            
        case (.partial(let selfPartial), .partial(let otherPartial)):
            return try selfPartial.merging(with: otherPartial)
            
        case (.full(let selfFull), .full(let otherFull)):
            return .full(try selfFull.merging(with: otherFull))
            
        case (.partial(let selfPartial), .full(let otherFull)):
            return .full(try otherFull.mergingWithPartial(selfPartial))
            
        case (.full(let selfFull), .partial(let otherPartial)):
            return .full(try selfFull.mergingWithPartial(otherPartial))
            
        }
    }
}

// MARK: - Value Retrival
public extension TokenDefinitionsState.Value {
    var full: TokenState? {
        guard case .full(let tokenState) = self else { return nil }
        return tokenState
    }
    
    var isFull: Bool {
        return full != nil
    }
    
    var isPartial: Bool {
        guard case .partial = self else { return false }
        return true
    }
}
