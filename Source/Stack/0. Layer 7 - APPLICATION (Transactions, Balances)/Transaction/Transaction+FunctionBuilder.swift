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

// MARK: - Void builder
public extension Transaction {
    @_functionBuilder
    struct VoidBuilder {
        static func buildBlock(_ userAction: UserAction) -> UserAction {
            return userAction
        }

        static func buildBlock(_ userActions: UserAction...) -> [UserAction] {
            return userActions
        }
    }
}

// MARK: - Transaction From VoidBuilder
public extension Transaction {
    init(@Transaction.VoidBuilder makeActions: () -> [UserAction]) {
        self.init(actions: makeActions())
    }

    init(@Transaction.VoidBuilder makeAction: () -> UserAction) {
        self.init(actions: [makeAction()])
    }
}

// MARK: - TokenContextBuilder
public extension Transaction {
    @_functionBuilder
    struct TokenContextBuilder {

        static func buildBlock(_ userActionMaking: UserActionMaking...) -> [UserActionMaking] {
            return userActionMaking
        }

        static func buildBlock(_ userActionMakingSingle: UserActionMaking) -> [UserActionMaking] {
            return [userActionMakingSingle]
        }
    }
}

// MARK: Transaction From TokenContextBuilder
public extension Transaction {
    init(
        _ tokenContext: TokenContext,
        
        @Transaction.TokenContextBuilder
        makeListOfUserActionMaking: () -> [UserActionMaking]
    ) {
        self.init(tokenContext: tokenContext, shorts: makeListOfUserActionMaking())
    }

    init(
        _ tokenContext: TokenContext,

        @Transaction.TokenContextBuilder
        makeUserActionMaking: () -> UserActionMaking
    ) {
        self.init(tokenContext: tokenContext, shorts: [makeUserActionMaking()])
    }
}

private extension Transaction {
    init(
        tokenContext: TokenContext,
        shorts: [UserActionMaking]
    ) {
        let userActions: [UserAction] = shorts.map { $0.makeSomeUserAction(tokenContext: tokenContext) }
        self.init(actions: userActions)
    }
}
