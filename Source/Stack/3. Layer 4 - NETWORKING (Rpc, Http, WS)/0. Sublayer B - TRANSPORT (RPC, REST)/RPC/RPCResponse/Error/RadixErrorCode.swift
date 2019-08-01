//
//  RadixErrorCode.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// https://radixdlt.atlassian.net/wiki/spaces/RDOC/pages/425787406/Error+formats#Errorformats-Radixerrorcodes
public enum RadixErrorCode: Int, Swift.Error, Decodable, Equatable {
    case atomCollision          = 1010
    case atomIllegalState       = 1011
    case atomUnsuitablePeer     = 1012
    case atomValidationError    = 1013
    case atomUnknownError       = 1014
    
    case invalidArgument        = 1040
    case failedPrecondition     = 1041
    case outOfRange             = 1042
    case unauthorized           = 1043
    case notFound               = 1044
    case endpointRetired        = 1045
    case limitExceeded          = 1046
    case nodeUnknown            = 1050
    case nodeInternal           = 1051
    case nodeOffline            = 1052
    case nodeUnavailable        = 1053
}
