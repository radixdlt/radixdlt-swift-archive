//
//  ChronoQuark.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum Timestamp: String, Hashable, Codable {
    case `default`
}

public struct ChronoQuark: QuarkConvertible {
    public let timestamps: [Timestamp: Date]
    
    public init(timestamp: Timestamp = .default, date: Date) {
        self.timestamps = [timestamp: date]
    }
}

public extension ChronoQuark {
    
    func time(for timestamp: Timestamp) -> Date? {
        return timestamps[timestamp]
    }
    
    var defaultTimestamp: Date? {
        return time(for: .default)
    }
}
