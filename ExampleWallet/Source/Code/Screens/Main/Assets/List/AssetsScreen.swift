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
    
    @Environment(\.sizeCategory) var sizeCategory
    
    @EnvironmentObject private var securePersistence: SecurePersistence
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var radix: Radix
    
    // MARK: - Stateful Properties
    @State private var isPresentingBackUpMnemonicWarningScreen = false
    @State private var isPresentingSwitchAccountScreen = false
}

// MARK: - View
extension AssetsScreen: View {
    var body: some View {
        VStack {
            assetsList
            receiveOrSendView()
        }
        .promptForBackingUpOf(
            mnemonic: self.securePersistence.mnemonic,
            if: self.radix.hasEverReceivedAnyTransactionToAnyAccount,
            isPresented: $isPresentingBackUpMnemonicWarningScreen,
            appState: self.appState
        )
    }
}

// MARK: - Subviews
private extension AssetsScreen {
    
    var assetsList: some View {
        List(self.assets) { asset in
            NavigationLink(destination:
                AssetDetailsScreen(
                    asset: asset,
                    myAddress: self.radix.myActiveAddress
                )
            ) {
                AssetRowView(asset: asset)
            }
        }.listStyle(GroupedListStyle())
    }
    
}

// MARK: - Data
private extension AssetsScreen {
    var assets: [Asset] {
        var radixAssets = radix.assets
        #if DEBUG
        radixAssets += mockTokenBalances()
        #endif
        return radixAssets
    }
}

// MARK: - View + Prompt for Backup
extension View {
    
    func promptForBackingUpOf(
        mnemonic: @autoclosure @escaping () -> Mnemonic?,
        `if` isNeeded: @autoclosure @escaping () -> Bool,
        isPresented: Binding<Bool>,
        after delay: DispatchTimeInterval = .seconds(1),
        appState: AppState
    ) -> some View {
        
        return self.sheet(
            isPresented: isPresented,
            onDismiss: {
                isPresented.wrappedValue = false
        }
        ) {
            BackUpMnemonicScreen(
                mnemonicToBackUp: mnemonic()!,
                isPresentingBackUpFlow: isPresented
            )
                .environmentObject(appState)
        }.onAppear {
            guard mnemonic() != nil && isNeeded() else { return }
            performOnMainThread(after: delay) {
                isPresented.wrappedValue = true
            }
        }
    }
}

// MARK: - ReceiveOrSendView

typealias ReceiveOrSendView = Either<ReceiveTransactionScreen, SendScreen>

func receiveOrSendView() -> ReceiveOrSendView {
    ReceiveOrSendView(primary: "Receive", secondary: "Send")
}

//struct ReceiveOrSendView {
//    @Environment(\.sizeCategory) var sizeCategory
//}
//
//extension ReceiveOrSendView: View {
//    var body: some View {
//        let buttons = Group {
//            NavigationLink(destination: ReceiveTransactionScreen()) {
//                Text("Receive").buttonStyleSapphire()
//            }
//
//            NavigationLink(destination: SendScreen()) {
//                Text("Send").buttonStyleEmerald()
//            }
//        }
//
//        return Group {
//            if sizeCategory == .accessibilityLarge {
//                VStack { buttons }
//            } else {
//                HStack { buttons }
//            }
//        }.padding()
//    }
//}
