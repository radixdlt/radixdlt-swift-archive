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

import RxSwift

final class AppCoordinator {

    private let preferences: Preferences
    private let securePersistence: SecurePersistence

    private let navigationHandler: (AnyScreen, TransitionAnimation) -> Void

    private let rxDisposeBag = RxSwift.DisposeBag()

    init(
        dependencies: (securePersistence: SecurePersistence, preferences: Preferences),
        navigator navigationHandler: @escaping (AnyScreen, TransitionAnimation) -> Void
    ) {
        self.preferences = dependencies.preferences
        self.securePersistence = dependencies.securePersistence
        self.navigationHandler = navigationHandler
    }
}

// MARK: Internal
internal extension AppCoordinator {
    func start() {
        navigate(to: initialDestination)
    }
}

// MARK: - Private

// MARK: Destination
private extension AppCoordinator {
    enum Destination {
        case welcome, getStarted, main
    }

    func navigate(to destination: Destination, transitionAnimation: TransitionAnimation = .flipFromLeft) {
        let screen = screenForDestination(destination)
        navigationHandler(screen, transitionAnimation)
    }

    func screenForDestination(_ destination: Destination) -> AnyScreen {
        switch destination {
        case .welcome: return AnyScreen(welcome)
        case .getStarted: return AnyScreen(getStarted)
        case .main: return AnyScreen(main)
        }
    }

    var initialDestination: Destination {

        guard preferences.hasAgreedToTermsAndPolicy else {
            return .welcome
        }

        guard securePersistence.isWalletSetup else {
            return .getStarted
        }

        return .main
    }
}

// MARK: - Screens
import RadixSDK
private extension AppCoordinator {
    var welcome: some Screen {
        WelcomeScreen()
            .environmentObject(
                WelcomeViewModel(
                    preferences: preferences,
                    termsHaveBeenAccepted: { [unowned self] in self.start() }
                )
            )
    }

    var getStarted: some Screen {
        GetStartedScreen()
            .environmentObject(
                GetStartedViewModel(
                    preferences: preferences,
                    securePersistence: securePersistence,
                    walletCreated: { [unowned self] in self.navigate(to: .main) }
                )
        )
    }

    var main: some Screen {
        guard let seedFromMnemonic = securePersistence.seedFromMnemonic else {
            incorrectImplementation("Should have seed saved")
        }
        let alias = preferences.identityAlias ?? "Unnamed"
        guard let identity = try? AbstractIdentity(seedFromMnemonic: seedFromMnemonic, alias: alias) else {
            incorrectImplementationShouldAlwaysBeAble(to: "Create Radix Application Client")
        }
        let radixApplicationClient = RadixApplicationClient(bootstrapConfig: UniverseBootstrap.localhostSingleNode, identity: identity)

        radixApplicationClient.pull().disposed(by: rxDisposeBag)

        return MainScreen().environmentObject(
            MainViewModel(
                radixApplicationClient: radixApplicationClient,
                preferences: preferences,
                securePersistence: securePersistence,
                walletDeleted: { [unowned self] in
                    self.navigate(to: .getStarted, transitionAnimation: .flipFromRight)
                }
            )
        )
    }
}
