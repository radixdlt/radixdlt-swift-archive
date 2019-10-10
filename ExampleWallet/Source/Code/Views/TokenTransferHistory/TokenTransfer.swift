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

// MARK: - TokenTransfer
struct TokenTransfer {
    
    private let transfer: RadixSDK.TransferTokensAction
    let iSpent: Bool
    
    init(
        transfer: RadixSDK.TransferTokensAction,
        iAmTheSender: (Address) -> Bool
    ) {
        self.transfer = transfer
        self.iSpent = iAmTheSender(transfer.sender)
    }
}

extension TokenTransfer {
    var amount: String {
        let minusOrPlus = iSpent ? "-" : "+"
        let amount = transfer.amount.displayInWholeDenominationFallbackToHighestPossible()
        return "\(minusOrPlus) \(amount) \(transfer.tokenResourceIdentifier.name.uppercased())"
    }
    
    var addressOfOther: Address {
        if iSpent {
            return transfer.recipient
        } else {
            return transfer.sender
        }
    }
    
    var transferType: TransferType {
        iSpent ? .iSpent : .iReceived
    }
}

// MARK: - Identifiable
extension TokenTransfer: Identifiable {
    var id: Int {
        transfer.hashValue
    }
}

// MARK: - TransferType
extension TokenTransfer {
    enum TransferType: Int, Equatable {
        case iSpent, iReceived
    }
}
