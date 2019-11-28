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

/// A transaction in progress of being sent to the Radix network
public final class PendingTransaction: TransactionConvertible {

    /// The transaction prepared by the user, consisting of one or many user actions
    /// from which an Atom has been derived.
    private let transaction: Transaction

    /// Status updates publisher on the submission of the Atom derived from the `transaction`.
    let status: AnyPublisher<SubmitAtomAction, TransactionError>
    
    /// A publisher which completes when this pending transaction either finishes with failure
    /// or is gets stored by some node.
    private let completionPublisher: AnyPublisher<Never, TransactionError>

    /// Errors that have occurred during preparation of the atom from the `transaction`.
    private var bufferedErrors = [TransactionError]()
    
    /// Subscription of buffered errors.
    private var cancellables = Set<AnyCancellable>()
    
    init(
        transaction: Transaction,
        transactionErrors: AnyPublisher<Never, TransactionError>,
        updates: AnyPublisher<SubmitAtomAction, Never>
    ) {
        
        self.transaction = transaction
        
        let statusUpdates: AnyPublisher<SubmitAtomAction, TransactionError> = updates
            .compactMap(typeAs: SubmitAtomActionStatus.self)
            .first()
            .setFailureType(to: TransactionError.self)
            .flatMap { $0.publisherCompleteOnStored() }
            .share()
            .eraseToAnyPublisher()
        
        self.status = statusUpdates
        
        let completionFromUpdates = statusUpdates.ignoreOutput().eraseToAnyPublisher()
        
        self.completionPublisher = transactionErrors
            .merge(with: completionFromUpdates)
            .prefix(untilCompletionFrom: completionFromUpdates)
            .share()
            .eraseToAnyPublisher()
        
        // TODO This can probably be done in a more elegant way, since some `TransactionError`
        // might be thrown during building of Atom, they will be thrown right away. It seems
        // this prematurely terminates the 'completionPublisher'. Thus we manually 'buffer'
        // these errors
        transactionErrors.sink(
            receiveError: { [unowned self] errorToBuffer in
                self.bufferedErrors.append(errorToBuffer)
            }
        ).store(in: &cancellables)
    }
}

// MARK: - Public
public extension PendingTransaction {
    
    /// A publisher which completes when this pending transaction either finishes with failure
    /// or is gets stored by some node.
    var completion: AnyPublisher<Never, TransactionError> {
        if let bufferedError = bufferedErrors.first {
            return Fail<Never, TransactionError>(error: bufferedError).eraseToAnyPublisher()
        } else {
            return completionPublisher
        }
    }
}

// MARK: TransactionConvertible
public extension PendingTransaction {
    var sentAt: Date { transaction.sentAt }
    var actions: [UserAction] { transaction.actions }
}

// MARK: - Private

// MARK: SubmitAtomActionStatus
private extension SubmitAtomActionStatus {
    func publisherCompleteOnStored() -> AnyPublisher<SubmitAtomAction, TransactionError> {
        switch statusEvent {
        case .stored:
            return Empty<SubmitAtomAction, TransactionError>(completeImmediately: true)
                .eraseToAnyPublisher()
        case .notStored(let reason):
            return Fail<SubmitAtomAction, TransactionError>(error: .submitAtomError(reason.error))
                .eraseToAnyPublisher()
        }
    }
}
