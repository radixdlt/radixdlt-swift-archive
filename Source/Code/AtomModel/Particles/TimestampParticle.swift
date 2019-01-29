//
//  TimestampParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct TimestampParticle: ParticleConvertible {
    public let quarks: Quarks
    
    public init(date: Date) {
        self.quarks = [ChronoQuark(date: date)]
    }
}

public extension TimestampParticle {
    func timestamp() -> Date? {
        return quark(type: ChronoQuark.self)?.defaultTimestamp
    }
}
