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

public struct Transaction: TransactionConvertible, ArrayConvertible, CustomStringConvertible {
    
    public let uuid: UUID
    public let sentAt: Date
    public let actions: [UserAction]
    
    fileprivate init(
        uuid: UUID = .init(),
        sentAt: Date = .init(),
        actions: [UserAction]
    ) {
        self.uuid = uuid
        self.sentAt = sentAt
        self.actions = actions
    }
}

public extension Transaction {
    @_functionBuilder
    struct Builder {
        static func buildBlock(_ userAction: UserAction) -> UserAction {
            return userAction
        }

        static func buildBlock(_ userActions: UserAction...) -> [UserAction] {
            return userActions
        }
    }
}

public extension Transaction {

    init(@Transaction.Builder makeActions: () -> [UserAction]) {
        self.init(actions: makeActions())
    }

    init(@Transaction.Builder makeAction: () -> UserAction) {
        self.init([makeAction()])
    }

    init(actions: UserAction...) {
        self.init(actions: actions)
    }

    init(_ actions: [UserAction]) {
          self.init(actions: actions)
    }
}

// MARK: ArrayConvertible
public extension Transaction {
    typealias Element = UserAction
    var elements: [Element] { return actions }
}

public extension Transaction {
    var description: String {
        let actionsString = actions.map { $0.nameOfAction.rawValue }.joined(separator: ", ")
        return """
        Transaction(actions: \(actionsString))
        """
    }
}
