//
//  AtomObservation.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum AtomObservation: Hashable {
    case store(atom: Atom, receivedAt: Date)
    case head(receivedAt: Date)
}

public extension AtomObservation {
    static func createStore(_ atom: Atom, receivedAt: Date = Date()) -> AtomObservation {
        return .store(atom: atom, receivedAt: receivedAt)
    }
    
    static func createHead(receivedAt: Date = Date()) -> AtomObservation {
        return .head(receivedAt: receivedAt)
    }
    
    var atom: Atom? {
        switch self {
        case .store(let atom, _): return atom
        case .head: return nil
        }
    }
    
    var isStore: Bool {
        guard case .store = self else { return false }
        return true
    }
    var isHead: Bool {
        guard case .head = self else { return false }
        return true
    }
}
