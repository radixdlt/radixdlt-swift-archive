//
//  ProofOfWorkWorker.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class ProofOfWorkWorker {
    private let dispatchQueue = DispatchQueue(label: "Radix.ProofOfWorkWorker", qos: .background)
    public init() {}
}

public extension ProofOfWorkWorker {
    static let expectedByteCountOfSeed = 32
    
    func work(
        seed: Data,
        magic: Magic,
        numberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = .default
        ) -> Observable<ProofOfWork> {
        
        return Observable.create { observer in
            
            var powDone = false
            let calculatePOW = self.prepareWork(seed: seed, magic: magic, observer: observer) {
                powDone = true
            }
            self.dispatchQueue.async(execute: calculatePOW)
            
            return Disposables.create {
                if !powDone {
                    log.warning("POW cancelled")
                    calculatePOW.cancel()
                }
            }
        }
    }
}

private extension ProofOfWorkWorker {
    
    func prepareWork<O>(
        seed: Data,
        magic: Magic,
        numberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = .default,
        observer: O,
        done: @escaping () -> Void
    ) -> DispatchWorkItem
        where
    O: ObserverType, O.E == ProofOfWork {

        return DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            log.verbose("POW started")
            return self.work(
                seed: seed,
                magic: magic,
                numberOfLeadingZeros: numberOfLeadingZeros
            ) { resultOfWork in
                switch resultOfWork {
                case .failure(let error):
                    observer.onError(error)
                case .success(let pow):
                    done()
                    log.verbose("POW done")
                    observer.onNext(pow)
                    observer.onCompleted()
                }
            }
        }
    }
}

// MARK: - Convenience
public extension ProofOfWorkWorker {
    func work(
        atom: Atom,
        magic: Magic,
        numberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = .default
        ) -> Observable<ProofOfWork> {
        
        return work(
            seed: atom.radixHash.asData,
            magic: magic,
            numberOfLeadingZeros: numberOfLeadingZeros
        )
    }
    
}

// MARK: - Private
private extension ProofOfWorkWorker {
    func work(
        seed: Data,
        magic: Magic,
        numberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = .default,
        done: ((Result<ProofOfWork, Error>) -> Void)
    ) {
        guard seed.length == ProofOfWorkWorker.expectedByteCountOfSeed else {
            let error = ProofOfWork.Error.workInputIncorrectLengthOfSeed(expectedByteCountOf: ProofOfWorkWorker.expectedByteCountOfSeed, butGot: seed.length)
            done(.failure(error))
            return
        }
        
        let numberOfBits = ProofOfWorkWorker.expectedByteCountOfSeed * Int.bitsPerByte
        var bitArray = BitArray(repeating: .one, count: numberOfBits)
        
        for index in 0..<Int(numberOfLeadingZeros.numberOfLeadingZeros) {
            bitArray[index] = .zero
        }
        
        let target = bitArray.asData
        let targetHex = bitArray.hex
        var nonce: Nonce = 0
        let base: Data = magic.toFourBigEndianBytes() + seed
        var hex: String
        repeat {
            nonce += 1
            let unhashed = base + nonce.toEightBigEndianBytes()
            hex = RadixHash(unhashedData: unhashed).hex
        } while hex > targetHex
        
        let pow = ProofOfWork(seed: seed, targetHex: target.toHexString(), magic: magic, nonce: nonce)
        done(.success(pow))
    }
    
}
