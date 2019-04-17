//
//  NodeAddressRequesting.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol NodeAddressRequesting {
    func findNode() -> SingleWanted<FormattedURL>
}
