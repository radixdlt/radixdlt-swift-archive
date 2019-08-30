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

final class AppModel: ObservableObject {
    @ObservedObject var appState = AppState()
    @ObservedObject var dependencies = Dependencies()

    let objectWillChange = PassthroughSubject<Void, Never>()

    private var cancellable: Cancellable?

    init() {
        cancellable = Publishers.CombineLatest(
            appState.objectWillChange,
            dependencies.objectWillChange
        ).eraseMapToVoid().subscribe(objectWillChange)

        goToNextScreen()

    }

    func hasAcceptedTermsAndPrivacyPolicy() {
        preferences.hasAgreedToTermsAndPolicy = true
        goToNextScreen()
    }

    func goToNextScreen() {
        let contentToGoTo = self.nextContent
        appState.rootContent = contentToGoTo
        print("Go to next screen: \(contentToGoTo)")
        objectWillChange.send()
    }

    var nextContent: RootContent {
        guard preferences.hasAgreedToTermsAndPolicy else {
            return .welcome
        }

        guard securePersistence.isWalletSetup else {
            return .getStarted
        }

        return .main
    }
}

enum RootContent: Int, Swift.Identifiable {
    case main

    // Onboarding
    case welcome, getStarted
}
extension Swift.Identifiable where Self: RawRepresentable, ID == RawValue {
    var id: ID { rawValue }
}

final class AppState: ObservableObject {
//    @Published var hasAcceptedTermsAndPrivacyPolicy = false
//    @Published var hasSetupWallet = false

    @Published var rootContent: RootContent?

//    let objectWillChange = PassthroughSubject<Void, Never>()
//
//    private var cancellable: Cancellable?
//
//    init() {
//        cancellable = Publishers.CombineLatest(
//            $hasAcceptedTermsAndPrivacyPolicy,
//            $hasSetupWallet
//        ).eraseMapToVoid().subscribe(objectWillChange)
//    }

}

final class Dependencies: ObservableObject {
    @ObservedObject var availableAtStart = AvailableAtStart()
    @ObservedObject var availableLater = AvailableLater()
}

extension Dependencies {
    final class AvailableAtStart: ObservableObject {
        @ObservedObject var preferences = Preferences.default
        @ObservedObject var securePersistence = SecurePersistence.new(nameSpace: "RadixWallet")
    }

    final class AvailableLater: ObservableObject {
//        @ObservedObject
        var radixApplicationClient: RadixApplicationClient? = nil
    }
}


//extension AppModel {
//
//    func handleSeed() {
//        guard let seedFromMnemonic = securePersistence.seedFromMnemonic else {
//            incorrectImplementation("Should have seed saved")
//        }
//        let alias = preferences.identityAlias ?? "Unnamed"
//        guard let identity = try? AbstractIdentity(seedFromMnemonic: seedFromMnemonic, alias: alias) else {
//            incorrectImplementationShouldAlwaysBeAble(to: "Create Radix Application Client")
//        }
//        let radixApplicationClient = RadixApplicationClient(bootstrapConfig: UniverseBootstrap.localhostSingleNode, identity: identity)
//
//        self.radix.radixApplicationClient = radixApplicationClient
//
//    }
//
//    var radixApplicationClient: RadixApplicationClient {
//        guard let radixApplicationClient = radix.radixApplicationClient else {
//            incorrectImplementation("Do not access the RadixApplicationClient until you KNOW that it is present")
//        }
//        return radixApplicationClient
//    }
//}

extension AppModel {
    var needsToBackupMnemonic: Bool { mnemonic != nil }

    var mnemonic: Mnemonic? {
        get {
            securePersistence.mnemonic
        }
        set { securePersistence.mnemonic = newValue }
    }

    var seedFromMnemonic: Data? {
        get {
            securePersistence.seedFromMnemonic
        }
        set { securePersistence.seedFromMnemonic = newValue }
    }

    func generatedNewMnemonic(_ newMnemonic: Mnemonic) {
        mnemonic = newMnemonic
        seedFromMnemonic = newMnemonic.seed
        goToNextScreen()
    }

    func deleteWallet() {
        securePersistence.deleteAll()
        goToNextScreen()
    }

    func clearPreferences() {
        preferences.deleteAll()
    }

    var securePersistence: SecurePersistence { dependencies.availableAtStart.securePersistence }
    var preferences: Preferences { dependencies.availableAtStart.preferences }
}
