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
import RxSwift

final class MainCoordinator: Coordinator {

    private weak var navigationController: UINavigationController?
    private let tabBarController = UITabBarController()

    var childCoordinators = [AnyCoordinator]()

    private unowned let radixApplicationClient: RadixApplicationClient
    private weak var navigation: AppNavigation?
    private let disposeBag = DisposeBag()

    init(navigationController: UINavigationController, radixApplicationClient: RadixApplicationClient, navigation: AppNavigation) {
        self.navigation = navigation
        self.navigationController = navigationController
        self.radixApplicationClient = radixApplicationClient
        radixApplicationClient.pull().disposed(by: disposeBag)

        // SEND
        let sendNavigationController = UINavigationController()
        sendNavigationController.tabBarItem = UITabBarItem("Send")
        start(coordinator: SendCoordinator(navigationController: sendNavigationController, radixApplicationClient: radixApplicationClient))

        // SETTINGS
        let settingsNavigationController = UINavigationController()
        settingsNavigationController.tabBarItem = UITabBarItem("Settings")
        start(coordinator: SettingsCoordinator(navigationController: settingsNavigationController, navigation: navigation, radixApplicationClient: radixApplicationClient))

        tabBarController.viewControllers = [
            sendNavigationController,
            settingsNavigationController
        ]

        navigationController.pushViewController(tabBarController, animated: false)
    }
}

protocol MainNavigator: AnyObject {
    func toSend()
    func toSettings()
}

// MARK: - Conformance: Navigator
extension MainCoordinator: MainNavigator {

    func toSend() {
        tabBarController.selectedIndex = 0
    }

    func toSettings() {
        tabBarController.selectedIndex = 1
    }

    func start() {
        toSend()
    }
}
