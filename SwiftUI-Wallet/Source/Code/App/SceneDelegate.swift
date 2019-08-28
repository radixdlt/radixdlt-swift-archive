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

import UIKit
import SwiftUI

import KeychainSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    fileprivate lazy var appCoordinator: AppCoordinator = {
        let rootViewController: UIHostingController<AnyView> = .init(rootView: EmptyView().eraseToAny())

        window?.rootViewController = rootViewController

        let navigationHandler: (AnyScreen, TransitionAnimation) -> Void = { [unowned rootViewController, window] (newRootScreen: AnyScreen, transitionAnimation: TransitionAnimation) in
            UIView.transition(
                with: window!,
                duration: 0.5,
                options: transitionAnimation.asUIKitTransitionAnimation,
                animations: { rootViewController.rootView = newRootScreen },
                completion: nil
            )
        }

        return AppCoordinator(
            dependencies: (
                keychainStore: KeyValueStore(KeychainSwift()),
                preferences: .default
            ),
            navigator: navigationHandler
        )
    }()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        self.window = .fromScene(scene)
        appCoordinator.start()
    }
}

enum TransitionAnimation {
    case flipFromLeft
    case flipFromRight
}

private extension TransitionAnimation {
    var asUIKitTransitionAnimation: UIView.AnimationOptions {
        switch self {
        case .flipFromLeft: return UIView.AnimationOptions.transitionFlipFromLeft
        case .flipFromRight: return UIView.AnimationOptions.transitionFlipFromRight
        }
    }
}
