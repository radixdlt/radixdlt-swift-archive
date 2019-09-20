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
import RadixSDK


struct SwitchAccountScreen {
    @EnvironmentObject private var radix: Radix
}

extension SwitchAccountScreen: View {
    var body: some View {
        NavigationView {
            VStack {
                List(radix.accounts) { account in
                    AccountCell(account: account, isSelected: self.isSelected(account)) {
                        self.switchAccount(to: account)
                    }
                }
                Button("Add new account") {
                    self.addNewAccount()
                }
            }.navigationBarTitle("Select account")
        }
    }
}

private extension SwitchAccountScreen {

    func addNewAccount() {
        radix.addNewAccount()
    }

    func switchAccount(to account: Account) {
        radix.switchAccount(to: account)
    }

    func isSelected(_ account: Account) -> Bool {
        radix.activeAccount == account
    }
}

struct AccountCell {
    private let account: Account
    private let action: () -> Void
    private let isSelected: Bool
    init(account: Account, isSelected: Bool, action: @escaping () -> Void) {
        self.account = account
        self.action = action
        self.isSelected = isSelected
    }
}
extension AccountCell: View {
    var body: some View {
        Button("\(account.name)\(isSelected.ifTrue { " ✅" })", action: action)
    }
}
