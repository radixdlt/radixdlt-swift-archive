//
//  IdentifiableQuark.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct IdentifiableQuark: QuarkConvertible {
    public let identifier: ResourceIdentifier
    
    public init(identifier: ResourceIdentifier) {
        self.identifier = identifier
    }
}
