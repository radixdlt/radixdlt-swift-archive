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
import SwiftUI

import Combine
import RadixSDK

public final class AppState: ObservableObject {

    @Published public private(set) var rootContent: RootContent = .welcome

    private let preferences: Preferences
    private let securePersistence: SecurePersistence

    private let _update: Update

    private var cancellable: Cancellable?

    init(
        preferences: Preferences,
        securePersistence: SecurePersistence
    ) {
        self.preferences = preferences
        self.securePersistence = securePersistence

        let triggerNavigationSubject = CurrentValueSubject<Void, Never>(())

        self._update = Update(
            preferences: preferences,
            securePersistence: securePersistence,
            triggerNavigation: { triggerNavigationSubject.send() }
        )

        cancellable = triggerNavigationSubject.sink { [unowned self] _ in
            self.goToNextScreen()
        }
    }
}

// MARK: - PRIVATE
private extension AppState {

    func goToNextScreen() {
        rootContent = nextContent
        objectWillChange.send()
    }

    var nextContent: RootContent {
        guard preferences.hasAgreedToTermsOfUse else {
            return .welcome
        }

        guard securePersistence.isWalletSetup else {
            return .getStarted
        }
        return .main
    }
}

// MARK: - PUBLIC

// MARK: Update State
public extension AppState {
    // Syntax sugar enforcing function calling notation `.update()` rather than `.update` to highlight mutating
    func update() -> Update { _update }
}

