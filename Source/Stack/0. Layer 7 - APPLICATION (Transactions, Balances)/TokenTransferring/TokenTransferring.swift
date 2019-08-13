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

/// Type that is can make transactions of different types between Radix accounts
public protocol TokenTransferring: ActiveAccountOwner {

    func transfer(tokens: TransferTokenAction) -> ResultOfUserAction
    func observeTokenTransfers(toOrFrom address: Address) -> Observable<TransferredTokens>
}

public extension TokenTransferring {
    func transferTokens(
        identifier tokenIdentifier: ResourceIdentifier,
        to recipient: AddressConvertible,
        amount: PositiveAmount,
        message: String,
        messageEncoding: String.Encoding = .default,
        from specifiedSender: AddressConvertible? = nil
        ) -> ResultOfUserAction {
        
        let attachment = message.toData(encodingForced: messageEncoding)
        
        return transferTokens(
            identifier: tokenIdentifier,
            to: recipient,
            amount: amount,
            attachment: attachment,
            from: specifiedSender
        )
    }
    
    func transferTokens(
        identifier tokenIdentifier: ResourceIdentifier,
        to recipient: AddressConvertible,
        amount: PositiveAmount,
        attachment: Data? = nil,
        from specifiedSender: AddressConvertible? = nil
    ) -> ResultOfUserAction {
        
        let action = actionTransferTokens(
            identifier: tokenIdentifier,
            to: recipient,
            amount: amount,
            attachment: attachment,
            from: specifiedSender
        )
        
        return transfer(tokens: action)
    }
}

public extension TokenTransferring {
    func actionTransferTokens(
        identifier tokenIdentifier: ResourceIdentifier,
        to recipient: AddressConvertible,
        amount: PositiveAmount,
        message: String,
        messageEncoding: String.Encoding = .default,
        from specifiedSender: AddressConvertible? = nil
    ) -> TransferTokenAction {
        
        let attachment = message.toData(encodingForced: messageEncoding)
        
        return actionTransferTokens(
            identifier: tokenIdentifier,
            to: recipient,
            amount: amount,
            attachment: attachment,
            from: specifiedSender
        )
    }
    
    func actionTransferTokens(
        identifier tokenIdentifier: ResourceIdentifier,
        to recipient: AddressConvertible,
        amount: PositiveAmount,
        attachment: Data? = nil,
        from specifiedSender: AddressConvertible? = nil
    ) -> TransferTokenAction {
        
        let sender = specifiedSender ?? addressOfActiveAccount
        
        let transferAction = TransferTokenAction(
            from: sender,
            to: recipient,
            amount: amount,
            tokenResourceIdentifier: tokenIdentifier,
            attachment: attachment
        )
        
        return transferAction
    }
}

public extension TokenTransferring {
    func observeMyTokenTransfers() -> Observable<TransferredTokens> {
        return observeTokenTransfers(toOrFrom: addressOfActiveAccount)
    }
}
