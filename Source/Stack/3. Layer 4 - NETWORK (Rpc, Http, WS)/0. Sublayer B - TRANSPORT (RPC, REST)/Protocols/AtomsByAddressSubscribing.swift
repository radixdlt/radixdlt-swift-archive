//
//  AtomsByAddressSubscribing.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol AtomsByAddressSubscribing {
    func subscribe(to address: Address, subscriberId: SubscriberId) -> Observable<AtomSubscription>
}
