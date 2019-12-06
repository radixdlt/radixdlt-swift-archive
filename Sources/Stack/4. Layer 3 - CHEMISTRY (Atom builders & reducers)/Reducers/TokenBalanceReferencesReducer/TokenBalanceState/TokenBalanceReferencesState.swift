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

public struct TokenBalanceReferencesState: ApplicationState, DictionaryConvertible, Equatable {

    public typealias Key = ResourceIdentifier
    public typealias Value = TokenReferenceBalance

    public let dictionary: Map

    public init(dictionary: Map = [:]) {
        self.dictionary = dictionary
    }
}

public extension TokenBalanceReferencesState {
    var tokenReferenceBalances: [TokenReferenceBalance] {
        dictionary.values.map { $0 }
    }
}

// MARK: Convenience Init
public extension TokenBalanceReferencesState {
    init(reducing balances: [TokenReferenceBalance]) {
        self.init(dictionary: TokenBalanceReferencesState.reduce(balances))
    }
}

// MARK: Value Retrieval
public extension TokenBalanceReferencesState {
    func tokenReferenceBalance(of tokenIdentifier: ResourceIdentifier) -> TokenReferenceBalance? {
        return dictionary[tokenIdentifier]
    }
}

// MARK: Merge/Reduce State
public extension TokenBalanceReferencesState {

    func mergingWithTransferrableTokensParticle(_ transferrableTokensParticle: UpParticle<TransferrableTokensParticle>) -> TokenBalanceReferencesState {
        let stateFromParticle = TokenBalanceReferencesState(reducing: [TokenReferenceBalance(upTransferrableTokensParticle: transferrableTokensParticle)])
        return mergingWithState(stateFromParticle)
    }
    
}

public extension TokenBalanceReferencesState {

    static func reduce(_ balances: [TokenReferenceBalance]) -> Map {
        return Map(balances.map { ($0.tokenResourceIdentifier, $0) }, uniquingKeysWith: TokenBalanceReferencesState.conflictResolver)
    }

    static var conflictResolver: (TokenReferenceBalance, TokenReferenceBalance) -> TokenReferenceBalance {
        return { (current, new) in
            do {
                let merged = try current.merging(with: new)
                return merged
            } catch { incorrectImplementation("Unhandled error: \(error)") }
        }
    }

    func mergingWithState(_ otherState: TokenBalanceReferencesState) -> TokenBalanceReferencesState {
        return TokenBalanceReferencesState(
            dictionary: self.dictionary
                .merging(
                    otherState.dictionary,
                    uniquingKeysWith: TokenBalanceReferencesState.conflictResolver
                )
        )
    }

}
