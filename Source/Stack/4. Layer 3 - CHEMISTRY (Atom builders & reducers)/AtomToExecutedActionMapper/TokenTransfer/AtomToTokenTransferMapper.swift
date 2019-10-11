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

public protocol AtomToTokenTransferMapper: AtomToSpecificExecutedActionMapper where SpecificExecutedAction == TransferTokensAction {}

public final class DefaultAtomToTokenTransferMapper: AtomToTokenTransferMapper {
    public init() {}
}

public extension DefaultAtomToTokenTransferMapper {
    
    typealias SpecificExecutedAction = TransferTokensAction
    
    func mapAtomToActions(_ atom: Atom) -> CombineObservable<[TransferTokensAction]> {
        var transferredTokens = [TransferTokensAction]()
        
        for particleGroup in atom {
            guard let transfer = transferOfTokens(particleGroup: particleGroup, atomTimestamp: atom.timestamp) else { continue }
            transferredTokens.append(transfer)
        }
        
        return CombineObservable.just(transferredTokens)
    }
}

private func transferOfTokens(particleGroup: ParticleGroup, atomTimestamp: Date) -> TransferTokensAction? {
    guard
        let someTransferrableTokensParticleDown = particleGroup.firstTransferrableTokensParticle(spin: .down),
        case let rri = someTransferrableTokensParticleDown.tokenDefinitionReference,
        
        // This makes sure that `BurnAction` is not interpreted as `Transfer`
        !particleGroup.containsAnyUnallocatedTokensParticle(matchingIdentifier: rri, spin: .up),
        
        case let sender = someTransferrableTokensParticleDown.address,
        let recipientTransferrableTokensParticle = particleGroup.firstTransferrableTokensParticle(spin: .up, where: { $0.tokenDefinitionReference == rri && $0.address != sender })
        else {
            return nil
    }
    
    let recipient = recipientTransferrableTokensParticle.address
    
    let spunTransferrableTokensParticles = particleGroup.spunTransferrableTokensParticles(filter: { $0.tokenDefinitionReference == rri && $0.address == sender })
    
    let invertedSpunTransferrableTokensParticles = spunTransferrableTokensParticles.invertedSpin()
    
    let signedAmount = SignedAmount.fromSpunTransferrableTokens(particles: invertedSpunTransferrableTokensParticles)
    guard let positiveAmount = try? PositiveAmount(signed: signedAmount) else { return nil }

    return TransferTokensAction(
        from: sender,
        to: recipient,
        amount: positiveAmount,
        tokenResourceIdentifier: rri,
        attachment: particleGroup.attachmentData,
        date: atomTimestamp
    )
}

private extension ParticleGroup {
    var attachmentData: Data? {
        guard
            let attachmentBase64StringValue = self.metaData[MetaDataKey.attachment],
            let attachmentBase64String = try? Base64String(base64String: attachmentBase64StringValue)
            else { return nil }
        return attachmentBase64String.asData
    }
}
