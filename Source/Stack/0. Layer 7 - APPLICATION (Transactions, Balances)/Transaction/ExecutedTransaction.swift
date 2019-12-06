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

public struct ExecutedTransaction: TransactionConvertible, ArrayConvertible, CustomStringConvertible {
    public let atomIdentifier: AtomIdentifier
    public let date: Date
    public let actions: [UserAction]
    
    private init(
        atomIdentifier: AtomIdentifier,
        date registeredDate: Date,
        actions: [UserAction]
        ) {
        self.atomIdentifier = atomIdentifier
        self.date = registeredDate
        self.actions = actions
    }
}

public extension ExecutedTransaction {
    
    init(atom: Atom, actions: [UserAction]) {
        self.init(
            atomIdentifier: atom.identifier(),
            date: atom.timestamp,
            actions: actions
        )
    }
}

// MARK: ArrayConvertible
public extension ExecutedTransaction {
    typealias Element = UserAction
    var elements: [Element] { return actions }
}

public extension ExecutedTransaction {
    var description: String {
        let actionsString = actions.map { $0.nameOfAction.rawValue }.joined(separator: ", ")
        return """
        ExecutedTransaction(atomId: \(atomIdentifier.shortAid), actions: \(actionsString))
        """
    }
}
