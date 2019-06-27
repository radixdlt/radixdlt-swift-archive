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

import RxCocoa
import RxSwift
import RadixSDK

final class RestoreWalletViewModel {
    private let bag = DisposeBag()

    private weak var navigator: RestoreWalletNavigator?

    init(navigator: RestoreWalletNavigator) {
        self.navigator = navigator
    }
}

extension RestoreWalletViewModel: ViewModelType {

    struct Input {
        let privateKey: Driver<String?>
//        let encryptionPassword: Driver<String?>
//        let confirmEncryptionPassword: Driver<String?>
        let restoreTrigger: Driver<Void>
    }

    struct Output {
        let isRestoreButtonEnabled: Driver<Bool>
    }

    func transform(input: Input) -> Output {

        let validPrivateKey: Driver<PrivateKey?> = input.privateKey.filterNil().map {
            try? PrivateKey(hex: $0)
        }

        let isRestoreButtonEnabled = validPrivateKey.map { $0 != nil }

        let identity = validPrivateKey.filterNil().map { [unowned self] in
            self.identityFromPrivateKey(privateKey: $0)
        }

        input.restoreTrigger
            .withLatestFrom(identity).do(onNext: {
                let radixApi = DefaultRadixApplicationClient(bootstrapConfig: UniverseBootstrap.localhost, identity: $0)
                self.navigator?.toMain(radixApplicationClient: radixApi)
            }).drive().disposed(by: bag)

        return Output(
            isRestoreButtonEnabled: isRestoreButtonEnabled
        )
    }
}

private extension RestoreWalletViewModel {
    func identityFromPrivateKey(privateKey: PrivateKey, alias: String? = "restored") -> AbstractIdentity {
        let keyPair: KeyPair = KeyPair(private: privateKey)
        let account: Account = Account.privateKeyPresent(keyPair)
        let identity = try! AbstractIdentity(accounts: [account], alias: alias)
        return identity
    }
}
