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
    public let date: Date
    public let actions: [UserAction]
    
    fileprivate init(
        uuid: UUID = .init(),
        createdAt: Date = .init(),
        userActions actions: [UserAction]
    ) {
        self.uuid = uuid
        self.date = createdAt
        self.actions = actions
    }
}

public extension Transaction {
    init(actions: [UserAction]) {
        self.init(userActions: actions)
    }

    init(_ actions: UserAction...) {
        self.init(actions: actions)
    }
}

public extension Transaction {
    func addressesOfActionsAreInTheSameUniverseAs(activeAddress: Address) throws -> Throws<Void, ActionsToAtomError> {
        do {
            for action in actions {
                if let actionWithAddresses = action as? UserActionWithAddresses {
                    var addressesToCheck = actionWithAddresses.addresses
                    addressesToCheck.insert(activeAddress)
                    try Addresses.allInSameUniverse(addressesToCheck.asArray)
                }
            }
        } catch let actionsToAtomError as ActionsToAtomError {
            throw actionsToAtomError
        } catch {
            unexpectedlyMissedToCatch(error: error)
        }
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
