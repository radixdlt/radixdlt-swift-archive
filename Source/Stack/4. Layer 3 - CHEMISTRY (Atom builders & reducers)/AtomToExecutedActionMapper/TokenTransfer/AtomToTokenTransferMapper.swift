//
//  AtomToTokenTransferMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol AtomToTokenTransferMapper: AtomToSpecificExecutedActionMapper where SpecificExecutedAction == TransferredTokens {}

public final class DefaultAtomToTokenTransferMapper: AtomToTokenTransferMapper {
    public init() {}
}

public extension DefaultAtomToTokenTransferMapper {
    
    typealias SpecificExecutedAction = TransferredTokens
    
    // swiftlint:disable:next function_body_length
    func map(atom: Atom, account: Account) -> Observable<SpecificExecutedAction> {
        
        // swiftlint:disable:next function_body_length
        func transferredTokensFromParticleGroup(_ particleGroup: ParticleGroup) -> [TransferredTokens] {
            guard let anyConsumed = particleGroup.firstParticle(ofType: TransferrableTokensParticle.self, spin: .down) else {
                return []
            }
            let sender = anyConsumed.address
            
            var dictionary = [ResourceIdentifier: [Address: SignedAmount]]()
            
            particleGroup
                .compactMap({ try? SpunParticle<TransferrableTokensParticle>(anySpunParticle: $0) })
                .forEach { spunParticleTransferrableTokensParticle in
                    let particle = spunParticleTransferrableTokensParticle.particle
                    let spin = spunParticleTransferrableTokensParticle.spin
                    
                    var mapForRRi = dictionary.valueForKey(key: particle.tokenDefinitionReference) { [Address: SignedAmount]() }
                    let amountForParticle: SignedAmount = spin * particle.amount
                    let amountOrZero: SignedAmount = mapForRRi.valueForKey(key: particle.address) { SignedAmount.zero }
                    let updatedAmount: SignedAmount = amountOrZero + amountForParticle
                    mapForRRi[particle.address] = updatedAmount
                    dictionary[particle.tokenDefinitionReference] = mapForRRi
                }
            
            particleGroup.spunParticles.filter(spin: .down).compactMap({ $0.particle as? TransferrableTokensParticle }).forEach {
                guard $0.address == sender else {
                    incorrectImplementation("different senders...")
                }
            }
            
            return dictionary.map {
                let summary: [Address: SignedAmount] = $0.value
                
                let to: Address?
  
                switch summary.countedElementsZeroOneTwoAndMany {
                case .zero: incorrectImplementation("what?")
                case .one(let single): to = single.key
                case .two(let first, let secondAndLast):
                    to = first.value.isPositive ? first.key : secondAndLast.key
                case .many:
                    incorrectImplementation("should never happen, a transfer consists of one or two TransferrableTokensParticle in the same ParticleGroup. Two particles is used when 'change' needs to be returned to sender.")
                }
          
                guard let date = atom.timestamp else { incorrectImplementation("Should have timestamp") }
                guard let recipient = to else { incorrectImplementation("should have recipient") }
                
                // swiftlint:disable:next force_try force_unwrap
                let amount = try! PositiveAmount(nonNegative: summary.first!.value.abs)
                
                var attachment: Data?
                if
                    let attachmentBase64StringValue = particleGroup.metaData[MetaDataKey.attachment],
                    let attachmentBase64String = try? Base64String(base64String: attachmentBase64StringValue) {
                    attachment = attachmentBase64String.asData
                }
                    
                return TransferredTokens(
                    from: sender,
                    to: recipient,
                    amount: amount,
                    tokenResourceIdentifier: $0.key,
                    date: date,
                    attachment: attachment
                )
            }
        }
        
        let transferredTokensList: [TransferredTokens] = atom.particleGroups.flatMap(transferredTokensFromParticleGroup)
        
        return Observable.from(transferredTokensList)
    }
}
