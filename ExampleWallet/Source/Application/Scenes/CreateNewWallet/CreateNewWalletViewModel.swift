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
import RxSwift
import RxCocoa
// import FormValidatorSwift
import RadixSDK

final class CreateNewWalletViewModel {

    private let bag = DisposeBag()

    private weak var navigator: CreateNewWalletNavigator?

//    private unowned let radixApplicationClient: RadixApplicationClient

    init(navigator: CreateNewWalletNavigator) {
        self.navigator = navigator
//        self.radixApplicationClient = radixApplicationClient
    }
}

extension CreateNewWalletViewModel: ViewModelType {

    struct Input {
        let identityAlias: Driver<String?>
//        let confirmedEncryptionPassword: Driver<String?>
        let createWalletTrigger: Driver<Void>
    }

    struct Output {
//        let isCreateWalletButtonEnabled: Driver<Bool>
    }

    func transform(input: Input) -> Output {

//        let validEncryptionPassword: Driver<String?> = Driver.combineLatest(input.encryptionPassword, input.confirmedEncryptionPassword) {
//            guard
//                $0 == $1,
//                let newPassword = $0,
//                newPassword.count >= 3
//                else { return nil }
//            return newPassword
//        }
//
//        let isCreateWalletButtonEnabled = validEncryptionPassword.map { $0 != nil }
        
        
//        input.createWalletTrigger.withLatestFrom(validEncryptionPassword.filterNil()) { $1 }
            input.createWalletTrigger.withLatestFrom(input.identityAlias).map { [unowned self] in
                let identity = self.newIdentity(alias: $0)
                return RadixApplicationClient(bootstrapConfig: UniverseBootstrap.localhostSingleNode, identity: identity)
//                    .createNewWallet(encryptionPassword: $0, kdf: .scrypt)
//                    .asDriverOnErrorReturnEmpty()
            }
                .do(onNext: { self.navigator?.toMain(radixApplicationClient: $0) } )
            .drive()
            .disposed(by: bag)
        
        
        return Output(
//            isCreateWalletButtonEnabled: isCreateWalletButtonEnabled
        )
    }

}

private extension CreateNewWalletViewModel {
    func newIdentity(alias: String?) -> AbstractIdentity {
        let keyPair: KeyPair = KeyPair()
        let account: Account = Account.privateKeyPresent(keyPair)
        let identity = AbstractIdentity(accounts: [account], alias: alias)
        return identity
    }
}
