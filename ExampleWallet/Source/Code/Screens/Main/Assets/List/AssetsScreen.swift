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

    @EnvironmentObject private var appState: AppState

    // MARK: - Stateful Properties
    @State private var isShowingBackUpMnemonicWarningToast = false
}

// MARK: - View
extension AssetsScreen: View {
    var body: some View {
        VStack {
            backUpMnemonicWarningNotification
            assetsList
            sendOrReceiveTransactionButtons
        }
        .onAppear {
            self.presentBackUpMnemonicWarningIfNeeded()
        }
    }
}

private extension AssetsScreen {
    var backUpMnemonicWarningNotification: some View {
        Group {
            if appState.needsToBackupMnemonic {
                BackUpMnemonicWarningView()
                    .frame(height: isShowingBackUpMnemonicWarningToast ? 200 : 0, alignment: .top)
                    .animation(Animation.spring())
            } else {
                EmptyView()
            }

        }
    }

    var assetsList: some View {
        List(assets) {
             AssetRowView(asset: $0)
         }.listStyle(GroupedListStyle())
    }

    var sendOrReceiveTransactionButtons: some View {
        HStack {
            NavigationLink(destination: ReceiveTransactionScreen()) {
                Text("Receive").buttonStyleSaphire()
            }

            NavigationLink(destination: SendScreen()) {
                Text("Send").buttonStyleEmerald()
            }
        }.padding()
    }
}

private extension AssetsScreen {
    func presentBackUpMnemonicWarningIfNeeded(delay: DispatchTimeInterval = .seconds(1)) {
        guard appState.needsToBackupMnemonic else { return }
        performOnMainThread(after: delay) {
            self.isShowingBackUpMnemonicWarningToast = true
        }
    }
}

private extension AssetsScreen {

    var assets: [Asset] {
        return mockTokenBalances().map {
            Asset(tokenBalance: $0)
        }
    }
}

struct SendScreen {}
extension SendScreen: View {
    var body: some View {
        Text("Send screen")
    }
}
