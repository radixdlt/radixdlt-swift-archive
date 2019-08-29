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

import SwiftUI
import Combine

import RadixSDK

import RxSwift

struct ReceiveTransactionScreen {
    @EnvironmentObject private var viewModel: ViewModel
    @State private var isShowingCopiedAddressAlert = false
}

// MARK: - View
extension ReceiveTransactionScreen: Screen {
    var body: some View {
        VStack {
            Text("Your address").font(.roboto(size: 30))
            qrCodeImage
            myAddressView
        }
        .padding()
        .navigationBarTitle("Receive payment")
    }
}

private extension ReceiveTransactionScreen {

    var myAddressView: some View {
        AddressView(address: viewModel.myAddress)
    }

    var qrCodeImage: some View {
        QRCodeImage(string: viewModel.myAddressBase58String).frame(width: 300, height: 300, alignment: .center)
    }
}

// MARK: - ViewModel
typealias ReceiveTransactionViewModel = ReceiveTransactionScreen.ViewModel

extension ReceiveTransactionScreen {
    final class ViewModel: ObservableObject {

        // MARK: Injected Properties
        private let radixApplicationClient: RadixApplicationClient
        private let securePersistance: SecurePersistence

        // MARK: Stateful Properties
        @Published private var myActiveAddress: Address

        // MARK: Other properites
        private let rxDisposeBag = RxSwift.DisposeBag()

        init(
            radixApplicationClient: RadixApplicationClient,
            securePersistance: SecurePersistence
        ) {
            self.radixApplicationClient = radixApplicationClient
            self.securePersistance = securePersistance

            self.myActiveAddress = radixApplicationClient.addressOfActiveAccount

            // Subscribe to change of address (when changing active account)
            radixApplicationClient.observeAddressOfActiveAccount()
                .subscribe(onNext: { [unowned self] newAddress in
                    self.myActiveAddress = newAddress
                })
                .disposed(by: rxDisposeBag)
        }
    }
}

extension ReceiveTransactionViewModel {
    var myAddress: Address { myActiveAddress }
    var myAddressBase58String: String {
        myAddress.base58String.stringValue
    }
}

