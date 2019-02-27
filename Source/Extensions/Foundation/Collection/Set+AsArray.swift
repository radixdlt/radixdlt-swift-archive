//
//  Set+AsArray.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Set {
    var asArray: [Element] {
        return [Element](self)
    }
}
