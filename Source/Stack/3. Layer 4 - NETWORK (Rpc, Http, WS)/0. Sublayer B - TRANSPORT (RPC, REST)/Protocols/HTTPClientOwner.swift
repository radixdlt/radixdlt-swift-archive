//
//  HTTPClientOwner.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol HTTPClientOwner {
    var httpClient: HTTPClient { get }
}