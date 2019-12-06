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

// swiftlint:disable opening_brace

public protocol AtomToCreateTokenMapper:
AtomToSpecificExecutedActionMapper
where
    SpecificExecutedAction == CreateTokenAction,
    SpecificMappingError == Never
{}

// swiftlint:enable opening_brace

public extension AtomToCreateTokenMapper {
    
    func mapAtomToActions(_ atom: Atom) -> AnyPublisher<[CreateTokenAction], SpecificMappingError> {
        
        var createTokenActions = [CreateTokenAction]()
        
        for particleGroup in atom {
            guard
                let createTokenAction = createTokensActionFrom(
                    particleGroup: particleGroup,
                    atomIdentifier: atom.identifier()
                    )
                else { continue }
            
            createTokenActions.append(createTokenAction)
        }
        
        return Just(createTokenActions).eraseToAnyPublisher()
    }
}

private func createTokensActionFrom(particleGroup: ParticleGroup, atomIdentifier: AtomIdentifier) -> CreateTokenAction? {
    guard
        let downedRRITokensParticle = particleGroup.firstRRIParticle(spin: .down),
        case let rri = downedRRITokensParticle.resourceIdentifier,
        let typedTokenDefinition = particleGroup.typedTokenDefinition(matchingIdentifier: rri)
        else { return nil }
    
    guard let derivedSupply = derivedSupplyFrom(typedTokenDefinition: typedTokenDefinition, particles: particleGroup.spunParticles, atomIdentifier: atomIdentifier) else {
        Swift.print("warning: Found TypeTokenDefinition: \(typedTokenDefinition), but no initial supply, this is probably incorrectly implemented.")
        return nil
    }
    return CreateTokenAction(derivedSupply: derivedSupply, tokenDefinition: typedTokenDefinition.tokenDefinition)
}

private func derivedSupplyFrom(
    typedTokenDefinition: TypedTokenDefinition,
    particles: [AnySpunParticle],
    atomIdentifier: AtomIdentifier
) -> CreateTokenAction.InitialSupply.DerivedFromAtom? {
    let rri = typedTokenDefinition.tokenDefinition.tokenDefinitionReference
    switch typedTokenDefinition {
    case .fixedSupplyTokenDefinitionParticle:
        guard
            let transferrableTokensParticle = particles.firstTransferrableTokensParticle(matchingIdentifier: rri, spin: .up)
            else {
                return nil
        }
        let positiveSupply = PositiveSupply(other: transferrableTokensParticle.amount)
        
        return .fixedInitialSupply(positiveSupply)
    case .mutableSupplyTokenDefinitionParticle:
        guard
            let unallocatedTokensParticle = particles.firstUnallocatedTokensParticle(matchingIdentifier: rri, spin: .up),
            // Mutable supply always starts of with Max, from which we can mint.
            unallocatedTokensParticle.amount == .max
        else { return nil }
        return .mutableSupply(initialSupplyInfoToBeFoundInAtomWithId: atomIdentifier)
    }
}

private extension CreateTokenAction {
    init(derivedSupply: InitialSupply.DerivedFromAtom, tokenDefinition: TokenConvertible) {
        self.init(
            creator: tokenDefinition.address,
            name: tokenDefinition.name,
            symbol: tokenDefinition.symbol,
            description: tokenDefinition.description,
            derivedSupply: derivedSupply,
            iconUrl: tokenDefinition.iconUrl,
            granularity: tokenDefinition.granularity,
            permissions: tokenDefinition.tokenPermissions
        )
    }
}

// MARK: DefaultAtomToCreateTokenMapper
public struct DefaultAtomToCreateTokenMapper: AtomToCreateTokenMapper {
    public typealias SpecificExecutedAction = CreateTokenAction
}

