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

struct AssetInfoView {
    let asset: Asset
    
    init(of asset: Asset) {
        self.asset = asset
    }
    
}

// MARK: - View
extension AssetInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Labelled("Your balance", value: asset.balanceOf)
                .fontForValue(.roboto(size: 40, weight: .regular))
            
            Labelled("Description", value: asset.tokenDescription)
            
            HStack(spacing: 30) {
                Labelled("Supply type", value: asset.supplyType)
                Spacer()
                Labelled("Total supply", value: asset.totalSupply)
            }
            
            Labelled("RRI", value: asset.rri)
            
        }
        .background(Color.Radix.sapphire)
        .foregroundColor(.white)
    }
}
