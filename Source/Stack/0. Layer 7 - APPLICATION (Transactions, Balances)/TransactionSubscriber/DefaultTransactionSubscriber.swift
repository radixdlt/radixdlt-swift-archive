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

public final class DefaultTransactionSubscriber: TransactionSubscriber {
    
    private let atomStore: AtomStore
    private let atomToTransactionMapper: AtomToTransactionMapper
    
    public init(
        atomStore: AtomStore,
        atomToTransactionMapper: AtomToTransactionMapper
    ) {
        self.atomStore = atomStore
        self.atomToTransactionMapper = atomToTransactionMapper
    }
}

public extension DefaultTransactionSubscriber {
    convenience init(
        atomStore: AtomStore,
        activeAccount: AnyPublisher<Account, Never>
    ) {
        self.init(
            atomStore: atomStore,
            atomToTransactionMapper: DefaultAtomToTransactionMapper(activeAccount: activeAccount)
        )
    }
}

// MARK: TransactionSubscriber
public extension DefaultTransactionSubscriber {
    
    func observeTransactions(at address: Address) -> AnyPublisher<ExecutedTransaction, Never> {
        atomStore.atomObservations(of: address)
            .compactMap { (atomObservation: AtomObservation) -> Atom? in
                guard case .store(let atom, _, _) = atomObservation else { return nil }
                return atom
            }
            .flatMap { [weak self] atom -> AnyPublisher<ExecutedTransaction, Never> in
                guard let self = self else {
                    return Empty<ExecutedTransaction, Never>.init(completeImmediately: true).eraseToAnyPublisher()
                }
                return self.atomToTransactionMapper.transactionFromAtom(atom)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: AtomToTransactionMapper
public extension DefaultTransactionSubscriber {
    func transactionFromAtom(_ atom: Atom) -> AnyPublisher<ExecutedTransaction, Never> {
        return atomToTransactionMapper.transactionFromAtom(atom)
    }
}
