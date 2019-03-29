//
//  AtomObservation.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum AtomObservation: Hashable {
    case store(atom: Atom, soft: Bool, receivedAt: Date)
    case head(receivedAt: Date)
    case resync(receivedAt: Date)
    case delete(atom: Atom, soft: Bool, receivedAt: Date)
}

public extension AtomObservation {
    /**
     * Describes the type of observation including whether the update is "soft", or a weakly
     * supported atom which could possibly be deleted soon
     */
    var isSoft: Bool {
        switch self {
        case .store(_, let isSoft, _): return isSoft
        case .head, .resync: return false
        case .delete(_, let isSoft, _): return isSoft
        }
    }
}

public extension AtomObservation {
    static func createStore(_ atom: Atom, isSoft: Bool = false, receivedAt: Date = Date()) -> AtomObservation {
        return .store(atom: atom, soft: isSoft, receivedAt: receivedAt)
    }
    
    static func createDelete(_ atom: Atom, isSoft: Bool = false, receivedAt: Date = Date()) -> AtomObservation {
        return .delete(atom: atom, soft: isSoft, receivedAt: receivedAt)
    }
    
    static func createHead(receivedAt: Date = Date()) -> AtomObservation {
        return .head(receivedAt: receivedAt)
    }
    
    static func createResync(receivedAt: Date = Date()) -> AtomObservation {
        return .resync(receivedAt: receivedAt)
    }
    
    init(_ atomEvent: AtomEvent) {
        let atom = atomEvent.atom
        switch atomEvent.type {
        case .delete: self = AtomObservation.createDelete(atom)
        case .store: self = AtomObservation.createStore(atom)
        }
    }
    
    var atom: Atom? {
        switch self {
        case .store(let atom, _, _): return atom
        case .delete(let atom, _, _): return atom
        case .head, .resync: return nil
        }
    }
    
    var receivedAt: Date {
        switch self {
        case .store(_, _, let date): return date
        case .delete(_, _, let date): return date
        case .head(let date): return date
        case .resync(let date): return date
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
    
    var isResync: Bool {
        guard case .resync = self else { return false }
        return true
    }

    var isDelete: Bool {
        guard case .delete = self else { return false }
        return true
    }
}
