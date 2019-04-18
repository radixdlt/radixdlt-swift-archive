//
//  RESTClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

public protocol RESTClient:
    NodeNetworkDetailsRequesting,
    LivePeersRequesting,
    NodeAddressRequesting
{
    // swiftlint:enable colon opening_brace
}
