// 
// MIT License
//
// Copyright (c) 2019 Radix DLT (https://radixdlt.com)
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

import UIKit
import RadixSDK

final class RestoreWalletCoordinator: AnyCoordinator {

    private weak var navigationController: UINavigationController?
    private weak var navigator: ChooseWalletNavigator?

    init(navigationController: UINavigationController?, navigator: ChooseWalletNavigator) {
        self.navigationController = navigationController
        self.navigator = navigator
    }
}

public protocol RestoreWalletNavigator: AnyObject {
    func toRestoreWallet()
    func toMain(radixApplicationClient: DefaultRadixApplicationClient)
}

// MARK: - Navigator
extension RestoreWalletCoordinator: RestoreWalletNavigator {

    func toMain(radixApplicationClient: DefaultRadixApplicationClient) {
        navigator?.toMain(radixApplicationClient: radixApplicationClient)
    }

    func toRestoreWallet() {
        let viewModel = RestoreWalletViewModel(navigator: self)
        let vc = RestoreWallet(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }

    func start() {
        toRestoreWallet()
    }
}