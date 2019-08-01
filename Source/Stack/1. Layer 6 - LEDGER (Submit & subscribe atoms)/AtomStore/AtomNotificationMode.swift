//
//  AtomNotificationMode.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
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
