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

struct MainScreen: Screen {

    var body: some View {
        TabView {
            tab(.assets) {
                AssetsScreen()
            }

            tab(.contacts) {
                ContactsScreen()
            }

            tab(.settings) {
                SettingsScreen()
            }
        }
        .font(.roboto(size: 20))

    }
}

private extension MainScreen {
    enum TabItem: Int {
        case assets
        case contacts
        case settings
    }

    func tab<S>(_ tab: TabItem, makeScreen: () -> S) -> some View where S: Screen {
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
        case .settings: return "Main.Tab.Name.Settings"
        }
    }

    var nameLocalized: String {
        return nameLocalizedStringKey.localized()
    }

    var image: Image {
        let name: String
        switch self {
            case .assets: name = "sterlingsign.circle"
            case .contacts: name = "book.circle"
            case .settings: name = "gear"
            }
        return Image(systemName: name)
    }
}

struct AssetsScreen: Screen {
    var body: some View {
        Text("Assets list overview")
    }
}

struct ContactsScreen: Screen {
    var body: some View {
        Text("Contacts list overview")
    }
}

struct SettingsScreen: Screen {
    var body: some View {
        Text("Settings")
    }
}

struct SwitchAccountsScreen: Screen {
    var body: some View {
        Text("Accounts list overview")
    }
}
