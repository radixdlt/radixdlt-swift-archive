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

struct AssetsScreen {
    @EnvironmentObject private var viewModel: ViewModel
}

// MARK: - View
extension AssetsScreen: Screen {
    var body: some View {
        VStack {
            if viewModel.needsToBackupMnemonic {
                BackUpMnemonicWarningView(
                    makeDestination: viewModel.makeBackUpScreen
                )  { self.viewModel.isShowingBackUpMnemonicWarningToast = false }
                    .frame(height: viewModel.isShowingBackUpMnemonicWarningToast ? 200 : 0, alignment: .top)
                    .animation(Animation.spring())
            } else { EmptyView() }

            List(viewModel.assets) {
                AssetRowView(asset: $0)
            }.listStyle(GroupedListStyle())
        }.onAppear { self.presentBackUpMnemonicWarningIfNeeded() }
    }
}

private extension AssetsScreen {
    func presentBackUpMnemonicWarningIfNeeded(delay: DispatchTimeInterval = .seconds(1)) {
        guard viewModel.needsToBackupMnemonic else { return }
        performOnMainThread(after: delay) {
            self.viewModel.isShowingBackUpMnemonicWarningToast = true
        }
    }
}

// MARK: - ViewModel
typealias AssetsViewModel = AssetsScreen.ViewModel
extension AssetsScreen {
    final class ViewModel: ObservableObject {
        @Published fileprivate var isShowingBackUpMnemonicWarningToast = false

        fileprivate let keychainStore: SecurePersistence

         init(
             keychainStore: SecurePersistence
         ) {
             self.keychainStore = keychainStore
         }
    }
}

private extension AssetsScreen.ViewModel {

    var assets: [Asset] {
        return mockTokenBalances().map {
            Asset(tokenBalance: $0)
        }
    }

    var needsToBackupMnemonic: Bool { keychainStore.mnemonic != nil }

    func makeBackUpScreen() -> AnyScreen {
        AnyScreen(
            BackUpMnemonicScreen()
                .environmentObject(
                    BackUpMnemonicViewModel(keychainStore: keychainStore) {
                        self.isShowingBackUpMnemonicWarningToast = false
                    }
            )
        )
    }
}
