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

struct AssetDetailsScreen {
    let asset: Asset
    let myAddress: Address
}

// MARK: View
extension AssetDetailsScreen: View {
    var body: some View {
        VStack(alignment: .leading) {
            List {
                AssetInfoView(of: asset).listRowInsets(EdgeInsets())
                
                TokenTransferHistoryView(for: asset, myAddress: myAddress)
            }
            
            VStack {
                receiveOrSendView()
                
                #if DEBUG
                mintOrBurnView(asset: asset, myAddress: myAddress)
                #endif
            }
        }
        .navigationBarTitle(asset.name)
    }
}

// MARK: - Debug
#if DEBUG

func mintOrBurnView(
    asset: Asset,
    myAddress: Address
) -> Either<MintTokensScreen, BurnTokensScreen> {
    
    let canMint = asset.token.canBeMinted(by: myAddress)
    let canBurn = asset.token.canBeBurned(by: myAddress)
    
    return Either(
        
        MintTokensScreen(asset: asset),
        present: canMint,
        color: Color.Radix.emerald,
        
        or:
        
        BurnTokensScreen(asset: asset),
        present: canBurn,
        color: Color.Radix.ruby
    )
}

#endif


// MARK: - Preview

#if DEBUG
struct AssetDetailsScreen_Previews: PreviewProvider {
    static var previews: some View {
        AssetDetailsScreen(
            asset: mockAssets()[1],
            myAddress: randomAddresses().randomElement()!
        )
    }
}

#endif
