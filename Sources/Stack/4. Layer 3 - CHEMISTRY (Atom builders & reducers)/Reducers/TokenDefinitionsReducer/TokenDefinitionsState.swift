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

public struct TokenDefinitionsState:
    ApplicationState,
    DictionaryConvertible,
    Equatable
{
    // swiftlint:enable colon opening_brace

    public typealias Key = ResourceIdentifier
    
    public var dictionary: Map
    public init(dictionary: Map = [:]) {
        self.dictionary = dictionary
    }
}

// MARK: Value
public extension TokenDefinitionsState {
    enum Value: TokenDefinitionReferencing, Equatable {
        case justToken(TokenDefinition)
        case justSupply(Supply, forToken: ResourceIdentifier)
        case full(TokenState)
    }
}

public extension TokenDefinitionsState.Value {
    var tokenDefinitionReference: ResourceIdentifier {
        switch self {
        case .full(let tokenState): return tokenState.tokenDefinitionReference
        case .justToken(let token): return token.tokenDefinitionReference
        case .justSupply(_, let rri): return rri
        }
    }
    
    var supply: Supply? {
        switch self {
        case .full(let tokenState): return tokenState.totalSupply
        case .justSupply(let supply, _): return supply
        case .justToken: return nil
        }
    }
}

// MARK: - Value Retrieval
public extension TokenDefinitionsState.Value {
    var full: TokenState? {
        guard case .full(let tokenState) = self else { return nil }
        return tokenState
    }
    
    var isFull: Bool {
        return full != nil
    }
}

public extension TokenDefinitionsState {
    func tokenDefinition(identifier: ResourceIdentifier) -> TokenDefinition? {
        guard let value = valueFor(identifier: identifier) else {
            return nil
        }
        switch value {
        case .full(let tokenState): return TokenDefinition(tokenConvertible: tokenState)
        case .justToken(let tokenDefinition): return tokenDefinition
        case .justSupply: return nil
        }
    }
    
    var tokenDefinitions: [TokenDefinition] {
        return self.dictionary.compactMap {
            self.tokenDefinition(identifier: $0.key)
        }
    }
    
    func valueFor(identifier: ResourceIdentifier) -> Value? {
        return dictionary[identifier]
    }
    
    func tokenState(identifier: ResourceIdentifier) -> TokenState? {
        guard let value = valueFor(identifier: identifier) else {
            return nil
        }
        switch value {
        case .full(let tokenState): return tokenState
        default: return nil
        }
    }
}
