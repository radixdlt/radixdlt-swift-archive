//
//  RPCClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

// swiftlint:disable colon opening_brace

public protocol RPCClient:
    FullDuplexCommunicating,
    NodeInfoRequesting,
    LivePeersRequesting,
    UniverseConfigRequesting,
    AtomQuerying,
    AtomSubmitting
{
    // swiftlint:enable colon opening_brace
    
    var channel: FullDuplexCommunicationChannel { get }
}
