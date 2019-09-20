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

import KingfisherSwiftUI

struct AssetRowView {

    @ObservedObject private var viewModel: ViewModel

    init(asset: Asset) {
        self.viewModel = ViewModel(asset: asset)
    }
}

// MARK: - View
extension AssetRowView: View {
    var body: some View {
        HStack {

            KFImage(viewModel.iconUrl)
                .placeholder {
                    Image(systemName: "arrow.2.circlepath.circle").font(.largeTitle)
                }
                .resizable()
                .frame(width: 32, height: 32, alignment: .center)

            Text(viewModel.name).font(.roboto(size: 18, weight: .regular))

            Spacer()

            Text(viewModel.balance).font(.roboto(size: 18, weight: .medium))
        }
        .foregroundColor(Color.Radix.dusk)
        .padding()
    }
}

// MARK: - ViewModel
extension AssetRowView {
    final class ViewModel: ObservableObject {
        private let asset: Asset

        init(asset: Asset) {
            self.asset = asset
        }
    }
}

extension AssetRowView.ViewModel {
    private var token: TokenDefinition { asset.tokenBalance.token }

    var name: String { token.name.stringValue }

    var balance: String { "\(asset.tokenBalance.amount.stringValue) \(token.symbol.stringValue)" }

    var iconUrl: URL { token.iconUrl ?? URL("127.0.0.1") }
}
