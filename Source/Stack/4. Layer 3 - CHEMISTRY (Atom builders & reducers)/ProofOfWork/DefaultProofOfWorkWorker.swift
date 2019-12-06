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

public final class DefaultProofOfWorkWorker: ProofOfWorkWorker {
    private let targetNumberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros
    private let sha256TwiceHasher: SHA256TwiceHashing

    public init(
        targetNumberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = .default,
        sha256TwiceHasher: SHA256TwiceHashing = SHA256TwiceHasher()
    ) {
        self.targetNumberOfLeadingZeros = targetNumberOfLeadingZeros
        self.sha256TwiceHasher = sha256TwiceHasher
    }
    
    deinit {
        print("POW Worker deinit")
    }
}

public extension DefaultProofOfWorkWorker {
    static let expectedByteCountOfSeed = 32
    
    func work(
        seed: Data,
        magic: Magic
    ) -> Future<ProofOfWork, ProofOfWork.Error> {
        
        return Future<ProofOfWork, ProofOfWork.Error> { promise in
            RadixSchedulers.backgroundScheduler.async {
                self.doWork(
                    seed: seed,
                    magic: magic
                ) { resultOfWork in
                    promise(resultOfWork)
                }
            }
        }
    }
}

// MARK: - Internal (for testing, ought to be private)
internal extension DefaultProofOfWorkWorker {
    func doWork(
        seed: Data,
        magic: Magic,
        done: ((Result<ProofOfWork, ProofOfWork.Error>) -> Void)
    ) {
        guard seed.length == DefaultProofOfWorkWorker.expectedByteCountOfSeed else {
            let error = ProofOfWork.Error.workInputIncorrectLengthOfSeed(expectedByteCountOf: DefaultProofOfWorkWorker.expectedByteCountOfSeed, butGot: seed.length)
            done(.failure(error))
            return
        }
        
        var nonce: Nonce = 0
        let base: Data = magic.toFourBigEndianBytes() + seed
        var radixHashedData = Data(capacity: 32)
        
        var unhashed = Data(capacity: base.count + 8)
        repeat {
            nonce += 1
            unhashed = base + nonce.toEightBigEndianBytes()
            radixHashedData = self.sha256TwiceHasher.sha256Twice(of: unhashed)
        } while radixHashedData.countNumberOfLeadingZeroBits() < targetNumberOfLeadingZeros.numberOfLeadingZeros
        
        let pow = ProofOfWork(seed: seed, targetNumberOfLeadingZeros: targetNumberOfLeadingZeros, magic: magic, nonce: nonce)
        done(.success(pow))
    }
}

extension DefaultProofOfWorkWorker: FeeMapper {}

public extension DefaultProofOfWorkWorker {
    
    func feeBasedOn(
        atom: Atom,
        universeConfig: UniverseConfig,
        key: PublicKey
    ) -> AnyPublisher<AtomWithFee, AtomWithFee.Error> {
        
        return work(atom: atom, magic: universeConfig.magic).tryMap {
            try AtomWithFee(atomWithoutPow: atom, proofOfWork: $0)
        }
        .mapError { castOrKill(instance: $0, toType: ProofOfWork.Error.self) }
        .mapError { AtomWithFee.Error.powError($0) }
        .eraseToAnyPublisher()
    }
}
