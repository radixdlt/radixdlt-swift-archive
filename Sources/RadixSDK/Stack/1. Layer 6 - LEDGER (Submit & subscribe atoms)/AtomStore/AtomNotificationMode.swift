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

private var nextOptionsAtomNotificationMode = 0
public struct AtomNotificationMode: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    private init(line: Int = #line) {
        rawValue = 1 << nextOptionsAtomNotificationMode
        nextOptionsAtomNotificationMode += 1
    }
}

// MARK: - Presets
public extension AtomNotificationMode {
    static let dontNotify = AtomNotificationMode()
    static let notifyOnAtomUpdate = AtomNotificationMode()
    static let notifyOnSync = AtomNotificationMode()
    static let notifyOnAtomUpdateAndSync: AtomNotificationMode = [.notifyOnAtomUpdate, .notifyOnSync]
    static let `default`: AtomNotificationMode = .notifyOnAtomUpdateAndSync
}

public extension AtomNotificationMode {
    var shouldNotifyOnAtomUpdate: Bool {
        return contains(.notifyOnAtomUpdate)
    }
    
    var shouldNotifyOnSync: Bool {
        return contains(.notifyOnSync)
    }
}
