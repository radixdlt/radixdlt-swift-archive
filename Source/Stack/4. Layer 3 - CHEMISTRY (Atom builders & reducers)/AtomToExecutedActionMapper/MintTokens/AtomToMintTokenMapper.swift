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

public protocol AtomToMintTokenMapper: AtomToSpecificExecutedActionMapper where SpecificExecutedAction == MintTokensAction {}

public extension AtomToMintTokenMapper {
    func mapAtomToActions(_ atom: Atom) -> AnyPublisher<[MintTokensAction], Never> {
        var mintActions = [MintTokensAction]()
        for particleGroup in atom {
            guard let mintAction = mintTokensActionFrom(particleGroup: particleGroup) else { continue }
            mintActions.append(mintAction)
        }
        
        return Just(mintActions).eraseToAnyPublisher()
    }
}

public extension NonNegativeAmount {
   
    static func fromTransferrableTokens(
        particles: [TransferrableTokensParticle],
        amountMapper: (TransferrableTokensParticle) -> NonNegativeAmount = { NonNegativeAmount(subset: $0.amount) }
    ) -> NonNegativeAmount {
        return reducing(particles.map(amountMapper))
    }
    
    static func reducing(_ amounts: [NonNegativeAmount]) -> NonNegativeAmount {
        return amounts.reduce(NonNegativeAmount.zero, +)
    }
}

enum SignedAmount {
    
    static func fromSpunTransferrableTokens(particles: [SpunParticle<TransferrableTokensParticle>]) -> BigSignedInt {
        let upParticles = particles.filter(spin: .up).map { $0.particle }
        let downParticles = particles.filter(spin: .down).map { $0.particle }
        
        let amountFromUpParticles = NonNegativeAmount.fromTransferrableTokens(particles: upParticles)
        let amountFromDownParticles = NonNegativeAmount.fromTransferrableTokens(particles: downParticles)
        return BigSignedInt(amountFromUpParticles.magnitude) - BigSignedInt(amountFromDownParticles)
    }
}

private func mintTokensActionFrom(particleGroup: ParticleGroup) -> MintTokensAction? {
    guard
        let unallocatedTokensParticle = particleGroup.firstUnallocatedTokensParticle(spin: .down),
        case let rri = unallocatedTokensParticle.tokenDefinitionReference,
        let firstTransferrableTokensParticle = particleGroup.firstTransferrableTokensParticle(matchingIdentifier: rri, spin: .up)
        else { return nil }
    
    let minter = firstTransferrableTokensParticle.address
    
    let spunTransferrableTokensParticles = particleGroup.spunTransferrableTokensParticles(filter: { $0.tokenDefinitionReference == rri && $0.address == minter })
    
    let signedAmount: BigSignedInt = SignedAmount.fromSpunTransferrableTokens(particles: spunTransferrableTokensParticles)
    guard let positiveAmount = try? PositiveAmount(signed: signedAmount) else { return nil }
    return MintTokensAction(tokenDefinitionReference: rri, amount: positiveAmount, minter: minter)
}

// MARK: DefaultAtomToMintTokenMapper
public struct DefaultAtomToMintTokenMapper: AtomToMintTokenMapper {
    public typealias SpecificExecutedAction = MintTokensAction
}
