//
//  BigInt+BigUInt+BigInteger.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import BigInt

public protocol BigInteger: BinaryInteger {}

public typealias BigSignedInt = BigInt
public typealias BigUnsignedInt = BigUInt
extension BigSignedInt: BigInteger {}
extension BigUnsignedInt: BigInteger {}
