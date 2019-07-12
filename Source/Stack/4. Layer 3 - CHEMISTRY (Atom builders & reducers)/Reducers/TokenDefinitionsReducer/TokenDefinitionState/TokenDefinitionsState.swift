//
//  TokenDefinitionsState.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
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
    
//    static func combine(state lhsState: TokenDefinitionsState, with rhsState: TokenDefinitionsState) -> TokenDefinitionsState {
//        if lhsState == rhsState { return lhsState }
//        return lhsState.merging(with: rhsState)
//    }
//
    func mergeWithTokenDefinitionParticle(_ tokenDefinitionParticle: TokenDefinitionParticle) -> TokenDefinitionsState {
        let value = Value(tokenDefinitionParticle: tokenDefinitionParticle)
        let otherState = TokenDefinitionsState(reducingValues: [value])
//        return TokenDefinitionsState.combine(state: self, with: otherState)
        return merging(with: otherState)
    }
    
    func mergeWithUnallocatedTokensParticle(_ unallocatedTokensParticle: UnallocatedTokensParticle) -> TokenDefinitionsState {
        let value = Value(unallocatedTokensParticle: unallocatedTokensParticle)
        let otherState = TokenDefinitionsState(reducingValues: [value])
//        return TokenDefinitionsState.combine(state: self, with: otherState)
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
