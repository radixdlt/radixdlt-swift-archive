//
//  TimeConverter.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public final class TimeConverter {
    
    static func stringFrom(date: Date) -> String {
        return millisecondsFrom(date: date).description
    }
    
    static func millisecondsFrom(date: Date) -> UInt64 {
        let seconds = date.timeIntervalSince1970
        let milliseconds = seconds * 1000
        
        // UInt64.max = 18446744073709, which will not overflow until
        // the year of 2554 (21 July), so it feels like a reasonable
        // technical debt.
        return UInt64(milliseconds)
    }
    
    static func dateFrom(string: String) -> Date? {
        guard let millisecondsSince1970 = TimeInterval(string) else {
            return nil
        }
        return dateFrom(millisecondsSince1970: millisecondsSince1970)
    }
    
    static func dateFrom(millisecondsSince1970: TimeInterval) -> Date {
        let secondsSince1970 = millisecondsSince1970 / 1000
        return Date(timeIntervalSince1970: secondsSince1970)
    }
}
