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
import RxSwift
import RxCocoa
import RadixSDK

// MARK: - SendView
final class SendView: ScrollingStackView {

    private lazy var walletBalanceView = WalletBalanceView()

    private lazy var recipientAddressField = UITextField.Style("To address", text: Address.with(privateKey: 1).stringValue).make()
    private lazy var amountToSendField = UITextField.Style("Rads", text: "1234").make()

    private lazy var sendButton = UIButton.Style("Send", isEnabled: false).make()
    private lazy var submittedAtomStatusLabel = UILabel.Style(numberOfLines: 0).make()

    // MARK: - StackViewStyling
    lazy var stackViewStyle: UIStackView.Style = [
        walletBalanceView,
        recipientAddressField,
        amountToSendField,
        sendButton,
        submittedAtomStatusLabel,
        .spacer
    ]
}

// MARK: - SingleContentView
extension SendView: ViewModelled {
    typealias ViewModel = SendViewModel

    var inputFromView: ViewModel.Input {
        return ViewModel.Input(
            fetchBalanceTrigger: rx.pullToRefreshTrigger,
            recepientAddress: recipientAddressField.rx.text.orEmpty.asDriver(),
            amountToSend: amountToSendField.rx.text.orEmpty.asDriver(),
            sendTrigger: sendButton.rx.tap.asDriver()
        )
    }

    func populate(with viewModel: ViewModel.Output) -> [Disposable] {
        return [
            viewModel.isFetchingBalance         --> rx.isRefreshing,
            viewModel.isSendButtonEnabled       --> sendButton.rx.isEnabled,
            viewModel.myAddress                 --> walletBalanceView.rx.address,
            viewModel.myXrdBalance              --> walletBalanceView.rx.balance,
            viewModel.statusOfSubmittedAtom     --> submittedAtomStatusLabel.rx.text
        ]
    }
}

// MARK: - ExpressibleByIntegerLiteral
/* For testing only. Do NOT use Int64 to create a private key */
extension PrivateKey: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        do {
            try self.init(scalar: BigUnsignedInt(value))
        } catch {
            fatalError("Bad value sent, error: \(error)")
        }
    }
}

extension Address {
    static func with(privateKey: PrivateKey, magic: Magic = -1332248574) -> Address {
        let publicKey = PublicKey(private: privateKey)
        return Address(magic: magic, publicKey: publicKey)
    }
}
