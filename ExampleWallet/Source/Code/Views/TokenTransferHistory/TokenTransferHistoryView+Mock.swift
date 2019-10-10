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

#if DEBUG
func mockTokenTransfersDuringPeriod(
    asset: Asset,
    myAddress: Address,
    numberOfDaysRange: Range<Int> = 3..<8,
    upUntilDate referenceDate: Date = .init(),
    numberOfTransfersPerDayRange txPerDayRange: Range<Int> = 1..<4
) -> [TokenTransfersDuringPeriod] {
    
    var periods = [TokenTransfersDuringPeriod]()
    
    let calendar = Calendar.current
    
    func mockTransfers(numberOfTransfers: Int) -> [TokenTransfer] {
        var transfers = [TokenTransfer]()
        
        let otherAddresses: [Address] = [
            "JF57CPSxkg1xXaob3sLKrtsmsG43dmAtjADnPJE9g3BLSADfhfZ",
            "JHWZuF9gcNKmJhHYSgF1s39r2BUxcmUYGQRrqSyotoSqzKCZVvF",
            "JFekjzr9AigFBdSQprMgJJVjHzPtJwbExNQpTLe4vqFcvKYrrJ5",
            "JFHrQXanUKFEdfB9W8MXHMPE6mFp8zEuW1gNZj5oQMi1WixgxSd",
            "JHbknGSx9AG4XiUA4ih1C94H5ppgUNo5zQJDjT5EQ5SvCpwiqWe",
            "JFbnroPqnGLU35qccGHaEwEbjAvD7ehH5wG9KEkc8xZbsSQ44Wx",
            "JHXqRzon4DAsbqSmxgGuMWoLXdcTjJadez1iYbvzsyJtEXFagnm",
            "JGMPHoiwsMQAjJCcDSjkhejHh1SSz7ztLgqNifmSr8fdVhnes3Y",
            "JGGoHWzvskZakA2tWnmyDCCdqABEv4fV49JLV81DEYKmk3vkHDd",
            "JEmGGNXnBqJbh6bTWJ5Uufbfc2bWV7rFPHvAjrZTtYxQE6p4Ses"
        ]
        
        for index in 0..<numberOfTransfers {
            let otherAddress = otherAddresses.randomElement()!
            let transferType = TokenTransfer.TransferType(rawValue: index % 2)!
            
            let recipient = transferType == .iReceived ? myAddress : otherAddress
            let sender = transferType == .iSpent ? myAddress : otherAddress
            
            let action = TransferTokensAction(
                from: sender,
                to: recipient,
                amount: PositiveAmount(Int.random(in: 1...1000)),
                tokenResourceIdentifier: asset.id
            )
            
            transfers.append(TokenTransfer(transfer: action) { $0 == myAddress })
        }
        
        return transfers
    }
    
    let numberOfDays = Int.random(in: numberOfDaysRange)
    
    for index in 0..<numberOfDays {
        let dayOffset = index - numberOfDays
        assert(dayOffset <= 0) // yes LEQ 0
        guard let date = calendar.date(byAdding: .day, value: dayOffset, to: referenceDate) else {
            incorrectImplementationShouldAlwaysBeAble(to: "generate date")
        }
        let transfers = mockTransfers(numberOfTransfers: Int.random(in: txPerDayRange))
        
        let period = TokenTransfersDuringPeriod(
            date: date,
            transfers: transfers
        )
        
        periods.append(period)
    }
    
    return periods
}

#endif


