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

struct Asset {
    let token: TokenDefinition
    private let balanceAmount: NonNegativeAmount
    
    init(tokenBalance: TokenBalance) {
        self.token = tokenBalance.token
        self.balanceAmount = tokenBalance.amount
    }
}

extension Asset: Identifiable {
    var id: ResourceIdentifier {
        token.tokenDefinitionReference
    }
    
    var rri: String {
        id.stringValue
    }
    
    var name: String {
        token.name.stringValue
    }
    
    var balance: String {
        balanceAmount.displayInWholeDenominationFallbackToHighestPossible()
    }
    
    var balanceOf: String {
        "\(balance) \(symbol)"
    }
    
    var symbol: String {
        token.symbol.stringValue
    }
    
    var tokenDescription: String {
        token.description.stringValue
    }
    
    var supplyType: String {
        token.tokenSupplyType.displayedString
    }
    
    var totalSupply: String {
        guard let supply = token.supply else {
            incorrectImplementation("Should always have supply, no?")
        }
        return supply.displayInWholeDenominationFallbackToHighestPossible()
    }
}

extension UnsignedAmount {
    func displayInWholeDenominationFallbackToHighestPossible() -> String {
        do {
            return try display(in: .whole)
        } catch {
            return displayUsingHighestPossibleNamedDenominator()
        }
    }
}
