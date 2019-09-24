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

    @EnvironmentObject private var securePersistence: SecurePersistence
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var radix: Radix

    // MARK: - Stateful Properties
    @State private var isShowingBackUpMnemonicWarningSheet = false
}

// MARK: - View
extension AssetsScreen: View {
    var body: some View {
        VStack {
            assetsList
            sendOrReceiveTransactionButtons
        }
        .sheet(
            isPresented: $isShowingBackUpMnemonicWarningSheet,
            onDismiss: {
                self.isShowingBackUpMnemonicWarningSheet = false
        }
        ) {
            BackUpMnemonicScreen(mnemonicToBackUp: self.securePersistence.mnemonic!, isPresentingBackUpFlow: self.$isShowingBackUpMnemonicWarningSheet)
                .environmentObject(self.appState)
        }
        .onAppear {
            self.presentBackUpMnemonicWarningIfNeeded()
        }
    }
}

private extension AssetsScreen {

    var assetsList: some View {
        List(radix.assets) { asset in
            AssetRowView(asset: asset)
                .contextMenu {
                    #if DEBUG
                    if self.hasUserPermission(toMint: asset) {
                        Button("🖨 Mint token") { self.mintAsset(asset) }
                    }
                    
                    if self.hasUserPermission(toBurn: asset) {
                        Button("🔥 Burn token") { self.burnAsset(asset) }
                    }
                    #endif
                        
                    Button("💸 Transfer token") {
                        self.transferAsset(asset)
                    }
                }
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
    
    func transferAsset(_ asset: Asset) {
        print("💸 Transfer: \(asset)")
    }
}

#if DEBUG
private extension AssetsScreen {
    
    func hasUserPermission(toMint asset: Asset) -> Bool {
        true
    }
    
    func hasUserPermission(toBurn asset: Asset) -> Bool {
        true
    }
    
    func mintAsset(_ asset: Asset) {
        print("🖨 Mint \(asset)")
    }
    
    func burnAsset(_ asset: Asset) {
         print("🔥 Burn \(asset)")
     }
}
#endif

private extension AssetsScreen {
    func presentBackUpMnemonicWarningIfNeeded(delay: DispatchTimeInterval = .seconds(1)) {
        guard needsToBackupMnemonic else { return }
        performOnMainThread(after: delay) {
            self.isShowingBackUpMnemonicWarningSheet = true
        }
    }

    var needsToBackupMnemonic: Bool {
        guard
            securePersistence.mnemonic != nil,
            radix.hasEverReceivedAnyTransactionToAnyAccount
        else { return false }
        return true
    }

}

extension Asset {
    enum Action {
        case transfer
        #if DEBUG
        case burn
        case mint
        #endif
    }
}
