//
//  File.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-31.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct ProofOfWork: CustomStringConvertible {
    
    private let seed: Data
    private let targetHex: HexString
    private let magic: Magic
    private let nonce: Nonce
    
    fileprivate init(seed: Data, targetHex: HexString, magic: Magic, nonce: Nonce) {
        self.seed = seed
        self.targetHex = targetHex
        self.magic = magic
        self.nonce = nonce
    }
}

// MARK: - Public
public extension ProofOfWork {
    var nonceAsString: String {
        return nonce.description
    }
}

// MARK: CustomStringConvertible
public extension ProofOfWork {
    var description: String {
        return nonceAsString
    }
}

import RxSwift
public final class ProofOfWorkWorker {
    private let dispatchQueue = DispatchQueue(label: "pow", qos: .background)
    public init() {}
    
    static let expectedByteCountOfSeed = 32
    
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
    
    func work(
        seed: Data,
        magic: Magic,
        numberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = .default
    ) -> Observable<ProofOfWork> {
        return Observable.deferred {
            return Observable.create { observer in
                
                let calculatePOW = DispatchWorkItem { [weak self] in
                    guard let self = self else { return }
                    return self.work(
                        seed: seed,
                        magic: magic,
                        numberOfLeadingZeros: numberOfLeadingZeros
                    ) { resultOfWork in
                        switch resultOfWork {
                        case .failure(let error):
                            observer.onError(error)
                        case .success(let pow):
                            observer.onNext(pow)
                            observer.onCompleted()
                        }
                    }
                }
                self.dispatchQueue.async(execute: calculatePOW)
                
                return Disposables.create {
                    calculatePOW.cancel()
                }
            }
        }
    }

    private func work(
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
        let base: Data = magicTo4BigEndianBytes(magic) + seed
        var hex: String
        repeat {
            nonce += 1
            let unhashed = base + nonce.as8BytesBigEndian
            hex = RadixHash(unhashedData: unhashed).hex
        } while hex > targetHex
        
        let pow = ProofOfWork(seed: seed, targetHex: target.toHexString(), magic: magic, nonce: nonce)
        done(.success(pow))
    }
    
}

public extension ProofOfWork {
    
    func prove() throws {
        let unhashed: Data = magicTo4BigEndianBytes(magic) + seed + nonce.as8BytesBigEndian
        let hashHex = RadixHash(unhashedData: unhashed).hex
        guard hashHex <= targetHex.hex else {
            throw Error.expected(hex: hashHex, toBeLessThanOrEqualToTargetHex: targetHex.hex)
        }
    }
}

// MARK: - Error
public extension ProofOfWork {
    enum Error: Swift.Error {
        case workInputIncorrectLengthOfSeed(expectedByteCountOf: Int, butGot: Int)
        case expected(hex: String, toBeLessThanOrEqualToTargetHex: String)
    }
}

// MARK: - Endianess (Matching Java library ByteStream `putInt`)
private func magicTo4BigEndianBytes(_ magic: Magic) -> [Byte] {
    let magic4Bytes = CFSwapInt32HostToBig(UInt32(magic)).bytes
    assert(magic4Bytes.count == 4)
    return magic4Bytes
}

// MARK: - Endianess (Matching Java library ByteStream `putLong`)
private extension Nonce {
    var as8BytesBigEndian: [Byte] {
        let nonce8Bytes = CFSwapInt64HostToBig(UInt64(value)).bytes
        assert(nonce8Bytes.count == 8)
        return nonce8Bytes
    }
}

