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

import RadixSDK

func mockTokenBalances() -> [TokenBalance] {
    return [
        TokenBalance(
            token:
            TokenDefinition(
                symbol: Symbol(validated: "XRD"),
                name: Name(validated: "Rads"),
                tokenDefinedBy: Address.genesis,
                granularity: .one,
                description: Description(validated: "Native currency on Radix"),
                tokenSupplyType: .fixed,
                iconUrl: URL(string: "https://assets.radixdlt.com/icons/icon-xrd-32x32.png")
            ),

            amount: 5000,

            owner: Address.genesis
        ),

        TokenBalance(
              token:
              TokenDefinition(
                  symbol: Symbol(validated: "TUSD"),
                  name: Name(validated: "True USD"),
                  tokenDefinedBy: Address.genesis,
                  granularity: .one,
                  description: Description(validated: "TrustToken's stablecoin back 1-for-1 with U.S. Dollars"),
                  tokenSupplyType: .fixed,
                  iconUrl: URL(string: "https://messari.io/asset-images/393807bc-0f39-44ea-80d2-580e770dca10/128.png?v=1")
              ),

              amount: 2300,

              owner: Address.genesis
        ),

        TokenBalance(
            token:
            TokenDefinition(
                symbol: Symbol(validated: "PAX"),
                name: Name(validated: "Paxos Standard"),
                tokenDefinedBy: Address.genesis,
                granularity: .one,
                description: Description(validated: "Transact at the speed of the internet"),
                tokenSupplyType: .fixed,
                iconUrl: URL(string: "https://messari.io/asset-images/ad1342eb-a5fe-4c60-b37e-71a8859f0fea/128.png?v=1")
            ),

            amount: 900,

            owner: Address.genesis
        )
    ]
}

private extension Address {
    static var genesis: Address {
        return try! Address(base58: "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor")
    }
}
