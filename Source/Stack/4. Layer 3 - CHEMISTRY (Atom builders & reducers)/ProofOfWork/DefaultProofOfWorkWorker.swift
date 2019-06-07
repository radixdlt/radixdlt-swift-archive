//
//  DefaultProofOfWorkWorker.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-07.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class DefaultProofOfWorkWorker: ProofOfWorkWorker {
    private let dispatchQueue = DispatchQueue(label: "Radix.DefaultProofOfWorkWorker", qos: .background)
    public init() {}
    
    deinit {
        log.verbose("POW Worker deinit")
    }
}

public extension DefaultProofOfWorkWorker {
    static let expectedByteCountOfSeed = 32
    
    // swiftlint:disable:next function_body_length
    func work(
        seed: Data,
        magic: Magic,
        numberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = .default
        ) -> Observable<ProofOfWork> {
        
        return Observable.create { [unowned self] observer in
            
            var powDone = false
            
            let calculatePOW = DispatchWorkItem {
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
                        powDone = true
                        log.verbose("POW done")
                        observer.onNext(pow)
                        observer.onCompleted()
                    }
                }
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

// MARK: - Private
private extension DefaultProofOfWorkWorker {
    func work(
        seed: Data,
        magic: Magic,
        numberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = .default,
        done: ((Result<ProofOfWork, Error>) -> Void)
        ) {
        guard seed.length == DefaultProofOfWorkWorker.expectedByteCountOfSeed else {
            let error = ProofOfWork.Error.workInputIncorrectLengthOfSeed(expectedByteCountOf: DefaultProofOfWorkWorker.expectedByteCountOfSeed, butGot: seed.length)
            done(.failure(error))
            return
        }
        
        let numberOfBits = DefaultProofOfWorkWorker.expectedByteCountOfSeed * Int.bitsPerByte
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
