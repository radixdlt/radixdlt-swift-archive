//
//  AtomStatusObservationCancelling.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-28.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol AtomStatusObservationCancelling {
    func closeAtomStatusNotifications(subscriberId: SubscriberId) -> Completable
}
