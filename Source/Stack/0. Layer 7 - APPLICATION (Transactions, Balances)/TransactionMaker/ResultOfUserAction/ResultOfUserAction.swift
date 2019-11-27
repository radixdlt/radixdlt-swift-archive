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

public final class ResultOfUserAction {
    
    let status: AnyPublisher<SubmitAtomAction, TransactionError>
    let completion: AnyPublisher<Never, TransactionError>
    
    init(
        updates: AnyPublisher<SubmitAtomAction, Never>,
        atom: AnyPublisher<SignedAtom, TransactionError>
    ) {
        
        let statusUpdates: AnyPublisher<SubmitAtomAction, TransactionError> = updates
            .compactMap(typeAs: SubmitAtomActionStatus.self)
            .first()
            .setFailureType(to: TransactionError.self)
            .flatMap { $0.publisherCompleteOnStored() }
            .share()
            .eraseToAnyPublisher()
        
        self.status = statusUpdates
        
        let completionFromUpdates = statusUpdates.ignoreOutput().eraseToAnyPublisher()
        
        let failureFromCreationOfSignedAtom: AnyPublisher<Never, TransactionError> = atom
            .flatMap { _ in
                // Should never finish, only complete with error
                Empty<Never, TransactionError>(completeImmediately: false)
            }
            .eraseToAnyPublisher()
        
        self.completion = failureFromCreationOfSignedAtom
            .merge(with: completionFromUpdates)
            .prefix(untilCompletionFrom: completionFromUpdates)
            .share()
            .eraseToAnyPublisher()
    }
}

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
