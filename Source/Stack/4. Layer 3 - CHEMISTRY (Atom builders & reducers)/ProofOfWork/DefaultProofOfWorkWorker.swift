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
    private let dispatchQueue = DispatchQueue(label: "Radix.DefaultProofOfWorkWorker", qos: .userInitiated)
    public init() {}
    
    deinit {
        log.verbose("POW Worker deinit")
    }
}

public extension DefaultProofOfWorkWorker {
    static let expectedByteCountOfSeed = 32
    
    func work(
        seed: Data,
        magic: Magic,
        numberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = .default
    ) -> Observable<ProofOfWork> {
        
        return Observable.create { [unowned self] observer in
            var powDone = false
            self.dispatchQueue.async {
                log.verbose("POW started")
                DefaultProofOfWorkWorker.work(
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
            
            return Disposables.create {
                if !powDone {
                    log.warning("POW cancelled")
                }
            }
        }
    }
}

// MARK: - Private
internal extension DefaultProofOfWorkWorker {
    static func work(
        seed: Data,
        magic: Magic,
        numberOfLeadingZeros targetNumberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = .default,
        done: ((Result<ProofOfWork, Error>) -> Void)
        ) {
        guard seed.length == DefaultProofOfWorkWorker.expectedByteCountOfSeed else {
            let error = ProofOfWork.Error.workInputIncorrectLengthOfSeed(expectedByteCountOf: DefaultProofOfWorkWorker.expectedByteCountOfSeed, butGot: seed.length)
            done(.failure(error))
            return
        }
        
        var nonce: Nonce = 0
        let base: Data = magic.toFourBigEndianBytes() + seed
        var radixHash: RadixHash!
        repeat {
            nonce += 1
            let unhashed = base + nonce.toEightBigEndianBytes()
            radixHash = RadixHash(unhashedData: unhashed)
        } while radixHash.numberOfLeadingZeroBits < targetNumberOfLeadingZeros.numberOfLeadingZeros
        
        let pow = ProofOfWork(seed: seed, targetNumberOfLeadingZeros: targetNumberOfLeadingZeros, magic: magic, nonce: nonce)
        done(.success(pow))
    }
    
}

// MARK: Data + NumberOfLeadingZeroBits
internal extension DataConvertible {
    var numberOfLeadingZeroBits: Int {
        let byteArray = self.bytes
        let bitsPerByte = Int.bitsPerByte
        guard let index = byteArray.firstIndex(where: { $0 != 0 }) else {
            return byteArray.count * bitsPerByte
        }
        
        // count zero bits in byte at index `index`
        let byte: Byte = byteArray[index]
        if byte == 0x00 {
            return index * bitsPerByte
        } else {
            return index * bitsPerByte + byte.leadingZeroBitCount
        }
    }
}

internal extension ProofOfWork.NumberOfLeadingZeros {
    static func < (lhs: Int, rhs: ProofOfWork.NumberOfLeadingZeros) -> Bool {
        return lhs < rhs.numberOfLeadingZeros
    }
    
    static func >= (lhs: Int, rhs: ProofOfWork.NumberOfLeadingZeros) -> Bool {
        return lhs >= rhs.numberOfLeadingZeros
    }
}

