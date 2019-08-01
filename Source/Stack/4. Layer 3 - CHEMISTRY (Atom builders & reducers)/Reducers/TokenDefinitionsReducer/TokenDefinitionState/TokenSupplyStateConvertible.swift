//
//  TokenSupplyStateConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol TokenSupplyStateConvertible: TokenDefinitionReferencing {
    var totalSupply: Supply { get }
}
