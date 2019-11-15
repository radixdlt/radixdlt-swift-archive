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
import Combine

public struct TokenBalancesReducer {
    public typealias TokenBalancesOfAddress = (Address) -> AnyPublisher<TokenBalances, Never>
    public let tokenBalancesOfAddress: TokenBalancesOfAddress
    init(tokenBalancesOfAddress: @escaping TokenBalancesOfAddress) {
        self.tokenBalancesOfAddress = tokenBalancesOfAddress
    }
}

public extension TokenBalancesReducer {
    
    // swiftlint:disable function_body_length
    
    // TODO: This can most likely be simplified a LOT.
    
    init(
        makeBalanceReferencesStatePublisher: @escaping (Address) -> AnyPublisher<TokenBalanceReferencesState, Never>,
        makeTokenDefinitionsPublisher: @escaping (Address) -> AnyPublisher<TokenDefinitionsState, Never>
    ) {
        // swiftlint:enable function_body_length
        self.init { address in
            
            let balanceReferencesStatePublisher = makeBalanceReferencesStatePublisher(address).share() // buffer?
            
            func newTokenDefinitionsStatePublisher(for someAddress: Address) -> AnyPublisher<TokenDefinitionsState, Never> {
                makeTokenDefinitionsPublisher(someAddress).share().eraseToAnyPublisher()
            }
            
            var tokenDefinitionPublishersMap: [Address: AnyPublisher<TokenDefinitionsState, Never>] = [
                address: newTokenDefinitionsStatePublisher(for: address)
            ]
            
            // MARK: TokenBalanceReferencesState --{trigger}--> TokenBalances
            let tokenBalancesTriggeredByBalanceUpdate = balanceReferencesStatePublisher
                .flatMap { (tokenBalanceReferencesState: TokenBalanceReferencesState) in
                    Publishers.Sequence<[TokenReferenceBalance], Never>(
                        sequence: tokenBalanceReferencesState.tokenReferenceBalances
                    )
                        .flatMap { tokenReferenceBalance -> AnyPublisher<TokenBalance, Never> in
                            let rri = tokenReferenceBalance.tokenResourceIdentifier
                            
                            return tokenDefinitionPublishersMap.valueForKey(key: rri.address) {
                                newTokenDefinitionsStatePublisher(for: rri.address)
                            }
                            .compactMap { tokenDefinitionState in
                                tokenDefinitionState.tokenDefinition(identifier: rri)
                            }
                            .tryMap { tokenDefinition -> TokenBalance in
                                try TokenBalance(
                                    tokenDefinition: tokenDefinition,
                                    tokenReferenceBalance: tokenReferenceBalance
                                )
                            }
                            .crashOnFailure()
                    }
                    .collect(tokenBalanceReferencesState.tokenReferenceBalances.count)
                    .tryMap { (tokenBalances: [TokenBalance]) -> TokenBalances in
                        try TokenBalances(balances: tokenBalances)
                    }
                    .crashOnFailure()
            }
            
            // MARK: TokenDefinitionsState --{trigger}--> TokenBalances
            let tokenBalancesTriggeredByTokenStateUpdate = tokenDefinitionPublishersMap[address]!
                .flatMap { (tokenDefinitionsState: TokenDefinitionsState) in
                    
                    Publishers.Sequence<[TokenDefinition], Never>(
                        sequence: tokenDefinitionsState.tokenDefinitions
                    ).combineLatest(balanceReferencesStatePublisher) {
                        (tokenDefinition: TokenDefinition, tokenBalanceReferencesState: TokenBalanceReferencesState) -> TokenBalance? in
                        guard let tokenReferenceBalance = tokenBalanceReferencesState.tokenReferenceBalance(of: tokenDefinition.tokenDefinitionReference) else {
                            return TokenBalance?.none
                        }
                        return TokenBalance(
                            token: tokenDefinition,
                            amount: tokenReferenceBalance.amount,
                            owner: tokenReferenceBalance.owner
                        )
                    }
                    .compactMap { $0 }
                    .tryMap { (tokenBalance: TokenBalance) -> TokenBalances in
                        try TokenBalances(balances: [tokenBalance])
                    }
                    .crashOnFailure()
            }
            
            return tokenBalancesTriggeredByBalanceUpdate
                .merge(with: tokenBalancesTriggeredByTokenStateUpdate)
                .tryScan(TokenBalances.empty, { try $0.merging(with: $1) })
                 .crashOnFailure()
                .eraseToAnyPublisher()
        }
        
    }
}

public extension TokenBalancesReducer {
    static func usingApplicationClient(_ app: RadixApplicationClient) -> Self {
        Self(
            makeBalanceReferencesStatePublisher: { [unowned app] in app.observeBalanceReferences(at: $0) },
            makeTokenDefinitionsPublisher: { [unowned app] in app.observeTokenDefinitions(at: $0) }
        )
    }
    
}
