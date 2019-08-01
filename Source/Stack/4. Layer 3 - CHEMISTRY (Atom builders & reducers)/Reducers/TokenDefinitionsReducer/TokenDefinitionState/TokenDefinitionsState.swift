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
    Throwing,
    Equatable
{
    // swiftlint:enable colon opening_brace

    public typealias Key = ResourceIdentifier
    
    public var dictionary: Map
    public init(dictionary: Map = [:]) {
        self.dictionary = dictionary
    }
}

// MARK: - Convenience Init
public extension TokenDefinitionsState {
    init(reducingValues values: [Value]) {
        self.init(dictionary: TokenDefinitionsState.reduce(values: values))
    }
}

// MARK: - Value Retrival
public extension TokenDefinitionsState {
    func tokenDefinition(identifier: ResourceIdentifier) -> TokenDefinition? {
        guard let value = valueFor(identifier: identifier) else {
            return nil
        }
        switch value {
        case .full(let tokenState): return TokenDefinition(tokenConvertible: tokenState)
        case .partial(let partial):
            switch partial {
            case .supply: return nil
            case .tokenDefinition(let tokenDefinition): return tokenDefinition
            }
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
        case .partial: return nil
        }
    }
}

// MARK: - Throwing
public extension TokenDefinitionsState {
    enum Error: Swift.Error, Equatable {
        case tokenDefinitionReferenceMismatch
    }
}

// MARK: - Merging
public extension TokenDefinitionsState {
    static func reduce(values: [Value]) -> Map {
        return Map(values.map { ($0.tokenDefinitionReference, $0) }, uniquingKeysWith: TokenDefinitionsState.conflictResolver)
    }
    
    static var conflictResolver: (Value, Value) -> Value {
        return { (current, new) in
            do {
                return try current.merging(with: new)
            } catch { incorrectImplementation("Unhandled error: \(error)") }
        }
    }
    
    func mergeWithTokenDefinitionParticle(_ tokenDefinitionParticle: TokenDefinitionParticle) -> TokenDefinitionsState {
        let value = Value(tokenDefinitionParticle: tokenDefinitionParticle)
        let otherState = TokenDefinitionsState(reducingValues: [value])
        return merging(with: otherState)
    }
    
    func mergeWithUnallocatedTokensParticle(_ unallocatedTokensParticle: UnallocatedTokensParticle) -> TokenDefinitionsState {
        let value = Value(unallocatedTokensParticle: unallocatedTokensParticle)
        let otherState = TokenDefinitionsState(reducingValues: [value])
        return merging(with: otherState)
    }
    
    func merging(with other: TokenDefinitionsState) -> TokenDefinitionsState {
        return TokenDefinitionsState(
            dictionary: self.dictionary
                .merging(
                    other.dictionary,
                    uniquingKeysWith: TokenDefinitionsState.conflictResolver
                )
        )
    }
}
