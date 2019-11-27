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

public enum TransactionError: Swift.Error, Equatable {
    case stageActionError(StageActionError)
    case addFeeError(AtomWithFee.Error)
    case signAtomError(SigningError)
    case submitAtomError(SubmitAtomError)
}

public extension TransactionError {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.stageActionError(let lhsStageActionError), .stageActionError(let rhsStageActionError)):
            return lhsStageActionError.isEqual(to: rhsStageActionError)
        case (.signAtomError(let lhsSigningError), .signAtomError(let rhsSigningError)):
            return lhsSigningError == rhsSigningError
        case (.submitAtomError(let lhsSubmitAtomError), .submitAtomError(let rhsSubmitAtomError)):
            return lhsSubmitAtomError == rhsSubmitAtomError
        default: return false
        }
    }
}
