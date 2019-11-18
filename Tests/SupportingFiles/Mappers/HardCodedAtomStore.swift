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

import XCTest
import Foundation
@testable import RadixSDK
import Combine

struct HardCodedAtomStore: AtomStore {
    private let upParticles: [AnyUpParticle]
    init(upParticles particles: [SpunParticleContainer] = []) {
        self.upParticles = particles.compactMap { try? AnyUpParticle(spunParticle: $0) }
    }
}

extension TransactionToAtomMapper {
    func atomFrom(actions: UserAction..., addressOfActiveAccount: Address = .irrelevant) throws -> Atom {
        try atomFrom(transaction: .init(actions: actions), addressOfActiveAccount: addressOfActiveAccount)
    }
}

extension HardCodedAtomStore {
    static func particlesFrom(transaction: Transaction, address: Address = .irrelevant) -> Self {
        let txToAtomMapper = DefaultTransactionToAtomMapper(atomStore: HardCodedAtomStore(upParticles: []) )

        let atom = try! txToAtomMapper.atomFrom(transaction: transaction, addressOfActiveAccount: address)

        return Self(upParticles: atom.upParticles())
    }
}

extension HardCodedAtomStore {
    
    func onSync(address: Address) -> AnyPublisher<Date, Never> {
        Empty<Date, Never>(completeImmediately: true)
            .eraseToAnyPublisher()
    }
    
    func atomObservations(of address: Address) -> AnyPublisher<AtomObservation, Never> {
        Empty<AtomObservation, Never>(completeImmediately: true)
            .eraseToAnyPublisher()
    }
    
    func upParticles(at address: Address) -> [AnyUpParticle] {
        return upParticles
    }
    
    func store(atomObservation: AtomObservation, address: Address, notifyListenerMode: AtomNotificationMode) {
        abstract()
    }
}
