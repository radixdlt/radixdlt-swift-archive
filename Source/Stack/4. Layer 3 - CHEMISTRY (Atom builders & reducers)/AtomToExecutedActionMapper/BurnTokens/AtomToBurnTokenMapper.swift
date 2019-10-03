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

public protocol AtomToBurnTokenMapper: AtomToSpecificExecutedActionMapper where SpecificExecutedAction == BurnTokensAction {}

public extension AtomToBurnTokenMapper {
    func mapAtomToActions(_ atom: Atom) -> Observable<[BurnTokensAction]> {
        var burnActions = [BurnTokensAction]()
        for particleGroup in atom {
            guard let burnAction = burnTokensActionFrom(particleGroup: particleGroup) else { continue }
            burnActions.append(burnAction)
        }
        
        return Observable.just(burnActions)
    }
}

private func burnTokensActionFrom(particleGroup: ParticleGroup) -> BurnTokensAction? {
    guard
        let unallocatedTokensParticle = particleGroup.firstUnallocatedTokensParticle(spin: .up),
        case let rri = unallocatedTokensParticle.tokenDefinitionReference,
        let firstTransferrableTokensParticle = particleGroup.firstTransferrableTokensParticle(spin: .down, where: { $0.tokenDefinitionReference == rri })
        else { return nil }
    
    let burner = firstTransferrableTokensParticle.address
    
    let spunTransferrableTokensParticles = particleGroup.spunTransferrableTokensParticles(filter: { $0.tokenDefinitionReference == rri && $0.address == burner })
    
    let invertedSpunTransferrableTokensParticles = spunTransferrableTokensParticles.invertedSpin()
    
    let signedAmount = SignedAmount.fromSpunTransferrableTokens(particles: invertedSpunTransferrableTokensParticles)
    guard let positiveAmount = try? PositiveAmount(signed: signedAmount) else { return nil }
    return BurnTokensAction(tokenDefinitionReference: rri, amount: positiveAmount, burner: burner)
}

// MARK: DefaultAtomToBurnTokenMapper
public struct DefaultAtomToBurnTokenMapper: AtomToBurnTokenMapper {
    public typealias SpecificExecutedAction = BurnTokensAction
}
