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
import Combine
import RadixSDK
import RxSwift

public typealias Client = RadixApplicationClient

public final class Radix: ObservableObject {

    private let client: Client

    public let objectWillChange = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    public var myActiveAddress: Address

    init(client: Client) {
        self.client = client
        self.myActiveAddress = client.addressOfActiveAccount

        forward(function: Client.observeAddressOfActiveAccount) { [unowned self] myNewActiveAddress in
            self.myActiveAddress = myNewActiveAddress
        }
    }

}

// MARK: - Private
private extension Radix {

    func forward<O, NextElement>(
        function: (Client) -> () -> O,
        notify: Bool = true,
        onNext: @escaping (NextElement) -> Void
    ) where O: ObservableConvertibleType, O.Element == NextElement {

        forward(
            observable: function(client)(),
            notify: notify,
            onNext: onNext
        )

    }

    func forward<O, NextElement>(
         from keyPath: KeyPath<Client, O>,
         notify: Bool = true,
         onNext: @escaping (NextElement) -> Void
     ) where O: ObservableConvertibleType, O.Element == NextElement {

        forward(
            observable: client[keyPath: keyPath],
            notify: notify,
            onNext: onNext
        )

     }

    func forward<O, NextElement>(
        observable: O,
        notify: Bool = true,
        onNext: @escaping (NextElement) -> Void
    ) where O: ObservableConvertibleType, O.Element == NextElement {

        observable
            .publisherAssertNoFailure
            .sink { [unowned self] (nextElement: NextElement) in
                onNext(nextElement)
                if notify {
                    self.objectWillChange.send()
                }
        }
        .store(in: &cancellables)

    }
}


// MARL: - State
public extension Radix {
    var hasEverReceivedAnyTransactionToAnyAccount: Bool {
        return true
    }
}
