//
//  CharacterSetSpecifying.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol CharacterSetSpecifying {
    static var allowedCharacters: CharacterSet { get }
}
