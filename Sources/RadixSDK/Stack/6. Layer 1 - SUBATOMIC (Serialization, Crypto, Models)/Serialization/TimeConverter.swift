//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

public enum TimeConverter {}
public extension TimeConverter {
    static func stringFrom(date: Date) -> String {
        return millisecondsFrom(date: date).description
    }
    
    static func readableStringFrom(date: Date, dateStyle: DateFormatter.Style = .long) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        return formatter.string(from: date)
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
