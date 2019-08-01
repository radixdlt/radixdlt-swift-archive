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

public final class DefaultProofOfWorkWorker: ProofOfWorkWorker {
    private let dispatchQueue = DispatchQueue(label: "Radix.DefaultProofOfWorkWorker", qos: .userInitiated)
    private let defaultNumberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros
    public init(defaultNumberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = .default) {
        self.defaultNumberOfLeadingZeros = defaultNumberOfLeadingZeros
    }
    
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
    ) -> Single<ProofOfWork> {
        return Single.create { [unowned self] single in
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
//                        observer.onError(error)
                        single(.error(error))
                    case .success(let pow):
                        powDone = true
                        log.verbose("POW done")
                        single(.success(pow))
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

extension DefaultProofOfWorkWorker: FeeMapper {}
public extension DefaultProofOfWorkWorker {
    func feeBasedOn(atom: Atom, universeConfig: UniverseConfig, key: PublicKey) -> Single<AtomWithFee> {
        return work(atom: atom, magic: universeConfig.magic, numberOfLeadingZeros: self.defaultNumberOfLeadingZeros).map {
            try AtomWithFee(atomWithoutPow: atom, proofOfWork: $0)
        }
    }
}
