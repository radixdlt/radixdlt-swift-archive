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
import RxSwift

public protocol AtomToCreateTokenMapper: AtomToSpecificExecutedActionMapper where SpecificExecutedAction == CreateTokenAction {}

public extension AtomToCreateTokenMapper {
    func mapAtomToActions(_ atom: Atom) -> Observable<[CreateTokenAction]> {
        var createTokenActions = [CreateTokenAction]()
        for particleGroup in atom {
            guard let createTokenAction = createTokensActionFrom(particleGroup: particleGroup) else { continue }
            createTokenActions.append(createTokenAction)
        }
        
        return Observable.just(createTokenActions)
    }
}

private func createTokensActionFrom(particleGroup: ParticleGroup) -> CreateTokenAction? {
    guard
        let downedRRITokensParticle = particleGroup.firstRRIParticle(spin: .down),
        case let rri = downedRRITokensParticle.resourceIdentifier,
        let typedTokenDefinition = particleGroup.typedTokenDefinition(matchingIdentifier: rri)
        else { return nil }
    
    guard let initialSupply = initialSupplyFrom(typedTokenDefinition: typedTokenDefinition, particles: particleGroup.spunParticles) else {
        log.warning("Found TypeTokenDefinition: \(typedTokenDefinition), but no initial supply, this is probably incorrectly implemented.")
        return nil
    }
    return CreateTokenAction(initialSupply: initialSupply, tokenDefinition: typedTokenDefinition.tokenDefinition)
}

private func initialSupplyFrom(typedTokenDefinition: TypedTokenDefinition, particles: [AnySpunParticle]) -> CreateTokenAction.InitialSupply? {
    let rri = typedTokenDefinition.tokenDefinition.tokenDefinitionReference
    switch typedTokenDefinition {
    case .fixedSupplyTokenDefinitionParticle:
        guard
            let transfP = particles.firstTransferrableTokensParticle(matchingIdentifier: rri, spin: .up),
            let positiveSupply = try? PositiveSupply(amount: transfP.amount)
            else {
                return nil
        }
        
        return .fixed(to: positiveSupply)
    case .mutableSupplyTokenDefinitionParticle:
        guard particles.containsAnyUnallocatedTokensParticle(matchingIdentifier: rri, spin: .up) else {
            return nil
        }
        
        // TODO: Would like to map to initial supply, but its information is in another ParticleGroup, see `CreateTokenActionToParticleGroupsMapper` for details. Also impossible to disambiguate between CreateTokenAction with mutable initial supply, and with zero supply and then a mint action.
        return .mutable(initial: nil)
    }
}

private extension CreateTokenAction {
    init(initialSupply: InitialSupply, tokenDefinition: TokenConvertible) {
        do {
            try self.init(
                creator: tokenDefinition.address,
                name: tokenDefinition.name,
                symbol: tokenDefinition.symbol,
                description: tokenDefinition.description,
                supply: initialSupply,
                granularity: tokenDefinition.granularity,
                iconUrl: tokenDefinition.iconUrl
            )
        } catch {
            incorrectImplementation("Should always be able to init `CreateTokenAction` from a `TokenConvertible`, got unexpected error: \(error)")
        }
    }
}

// MARK: DefaultAtomToCreateTokenMapper
public struct DefaultAtomToCreateTokenMapper: AtomToCreateTokenMapper {
    public typealias SpecificExecutedAction = CreateTokenAction
}

