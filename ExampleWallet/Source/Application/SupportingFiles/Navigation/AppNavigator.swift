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

final class AppCoordinator {

    private let window: UIWindow
    var childCoordinators = [AnyCoordinator]()

    init(window: UIWindow) {
        self.window = window
    }
}

extension AppCoordinator: Coordinator {
    func start() {
        if let identity = Unsafe︕！Cache.radixIdentity {
            toMain(
                radixApplicationClient: DefaultRadixApplicationClient(bootstrapConfig: UniverseBootstrap.localhost, identity: identity),
                shouldSaveIdentity: false
            )
        } else {
           toChooseWallet()
        }
    }
}

protocol AppNavigation: AnyObject {
    func toChooseWallet()
    func toMain(radixApplicationClient: DefaultRadixApplicationClient, shouldSaveIdentity: Bool)
}

// MARK: - Private
extension AppCoordinator: AppNavigation {
    func toChooseWallet() {
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        let chooseWalletCoordinator = ChooseWalletCoordinator(navigationController: navigationController, navigation: self)
        childCoordinators = [chooseWalletCoordinator]
        chooseWalletCoordinator.start()
    }

    func toMain(radixApplicationClient: DefaultRadixApplicationClient, shouldSaveIdentity: Bool = true) {
        if shouldSaveIdentity {
            Unsafe︕！Cache.unsafe︕！Store(identity: radixApplicationClient.identity)
        }
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        
        let mainCoordinator = MainCoordinator(
            navigationController: navigationController,
            radixApplicationClient: radixApplicationClient,
            navigation: self
        )
        
        childCoordinators = [mainCoordinator]
        mainCoordinator.start()
    }
}
