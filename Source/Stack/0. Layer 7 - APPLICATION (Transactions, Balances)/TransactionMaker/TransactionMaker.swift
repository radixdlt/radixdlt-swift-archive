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

public protocol TransactionMaker: TransactionToAtomMapper {
    func make(transaction: Transaction, to originNode: Node?) -> PendingTransaction
}

public extension TransactionMaker {
    
    func make(transaction: Transaction) -> PendingTransaction {
        make(transaction: transaction, to: nil)
    }
    
    func execute(actions: [UserAction], to originNode: Node? = nil) -> PendingTransaction {
        let transaction = Transaction(actions: actions)
        return make(transaction: transaction, to: originNode)
    }
    
    func execute(actions: UserAction..., to originNode: Node? = nil) -> PendingTransaction {
        execute(actions: actions, to: originNode)
    }
}
