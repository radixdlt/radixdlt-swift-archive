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

public protocol Transaction {
    var identifier: AtomIdentifier { get }
    var sentAt: Date { get }
    var actions: [UserAction] { get }
}

public extension Transaction {
    func containsAction<Action>(ofType actionType: Action.Type) -> Bool where Action: UserAction {
        return actions.contains(where: { type(of: $0) == actionType })
    }
    
    /// Boolean OR of `actionTypes`
    func contains(actionMatchingAnyType actionTypes: [UserAction.Type]) -> Bool {
        return actions.contains(where: { action in
            let typeOfAction = type(of: action)
            return actionTypes.contains(where: { $0 == typeOfAction }) }
        )
    }
    
    /// Boolean AND of `actionTypes`
    func contains(actionMatchingAll actionTypes: [UserAction.Type]) -> Bool {
        return actionTypes.reduce(true, { (goodSoFar, requiredActionType) -> Bool in
            return goodSoFar && self.actions.contains(where: { type(of: $0) == requiredActionType })
        })
    }
    
    func actions<Action>(ofType actionType: Action.Type) -> [Action] where Action: UserAction {
        return actions.compactMap { $0 as? Action }
    }
}

public struct ExecutedTransaction: Transaction, ArrayConvertible {
    public let identifier: AtomIdentifier
    public let sentAt: Date
    public let actions: [UserAction]
    
    private init(
        identifier: AtomIdentifier,
        sentAt: Date,
        actions: [UserAction]
    ) {
        self.identifier = identifier
        self.sentAt = sentAt
        self.actions = actions
        
        print("⚛️ ExecutedTransaction, actions: \(actions)")
    }
}

public extension ExecutedTransaction {
    
    init(atom: Atom, actions: NonEmptyArray<UserAction>) {
        
        print("⚛️ ExecutedTransaction.init")
        self.init(
            identifier: atom.identifier(),
            sentAt: atom.timestamp,
            actions: actions.elements
        )
    }
}

// MARK: ArrayConvertible
public extension ExecutedTransaction {
    typealias Element = UserAction
    var elements: [Element] { return actions }
}

public struct NewTransaction: Transaction {
    public let identifier: AtomIdentifier
    public let sentAt: Date
    public let actions: [UserAction]
    
    private init(
        identifier: AtomIdentifier,
        sentAt: Date,
        actions: [UserAction]
    ) {
        self.identifier = identifier
        self.sentAt = sentAt
        self.actions = actions
    }
}

public extension NewTransaction {
    
    final class Builder {
        private var stagedActions: [UserAction] = .init()
        func stage(action: UserAction) {
            
        }
    }
}
