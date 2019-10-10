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

struct MainScreen {

    @EnvironmentObject private var radix: Radix
    @EnvironmentObject private var securePersistence: SecurePersistence
    // MARK: Stateful Properties
    @State private var isPresentingSwitchAccountScreen = false
}

// MARK: - View
extension MainScreen: View {

    var body: some View {
        TabView {
            tab(.assets) {
                NavigationView {
                    AssetsScreen().environmentObject(securePersistence)
                    .navigationBarItems(
                        leading: faucetButtonIfDebug,
                        trailing: switchAccountButton
                    )
                }
            }

            tab(.settings) {
                NavigationView {
                    SettingsScreen()
                        .environmentObject(self.radix)
                }
            }
        }
        .font(.roboto(size: 20))
        .accentColor(Color.Radix.emerald)
        .sheet(isPresented: $isPresentingSwitchAccountScreen) {
            SwitchAccountScreen()
                .environmentObject(self.radix)
        }
    }
}


private extension MainScreen {
    var switchAccountButton: some View {
        Button(action: { self.isPresentingSwitchAccountScreen = true }) {
            Image("Icon/Button/Profile")
        }
    }
    
    var faucetButtonIfDebug: some View {
        if isDebug {
            #if DEBUG
            return Button(action: { self.radix.debug.requestTokensFromFaucet() }) {
                Text("🚰")
            }.eraseToAny()
            #else
            fatalError("should not happen")
            #endif
        } else {
            return EmptyView().eraseToAny()
        }
    }
}

// MARK: - DATA -


// MARK: - TabItem
private extension MainScreen {
    enum TabItem: Int {
        case assets
        case contacts
        case apps
        case learn
        case settings
    }

    func tab<V>(_ tab: TabItem, makeScreen: () -> V) -> some View where V: View {
        makeScreen()
            .tabItem {
                tab.image
                Text(verbatim: tab.nameLocalized)
        }
    }
}

private extension MainScreen.TabItem {
    private var nameLocalizedStringKey: LocalizedStringKeyTmp {
        switch self {
        case .assets: return "Main.Tab.Name.Assets"
        case .contacts: return "Main.Tab.Name.Contacts"
        case .apps: return "Main.Tab.Name.Apps"
        case .learn: return "Main.Tab.Name.Learn"
        case .settings: return "Main.Tab.Name.Settings"
        }
    }

    var nameLocalized: String {
        return nameLocalizedStringKey.localized()
    }

    var image: Image {
        let prefix = "Icon/TabBar"
        let name: String
        switch self {
        case .assets: name = "Assets"
        case .contacts: name = "Contacts"
        case .apps: name = "Apps"
        case .learn: name = "Learn"
        case .settings: name = "Settings"
        }
        return Image("\(prefix)/\(name)")
    }
}
