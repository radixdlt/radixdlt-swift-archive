//
//  AtomObservation.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-15.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum AtomObservation: Hashable, CustomStringConvertible {
    case store(atom: Atom, soft: Bool, receivedAt: Date)
    case head(receivedAt: Date)
    case delete(atom: Atom, soft: Bool, receivedAt: Date)
}

public extension AtomObservation {
    
    var typeName: String {
        switch self {
        case .store: return "store"
        case .head: return "head"
        case .delete: return "delete"
        }
    }
    
    var description: String {
        return """
        .\(typeName)(\((isStore || isDelete).ifTrue { "isSoft: \(isStore)" })\(atom.ifPresent { ", atomWithAID: \($0.shortAid)" }))
        """
    }
    
    /**
     * Describes the type of observation including whether the update is "soft", or a weakly
     * supported atom which could possibly be deleted soon
     */
    var isSoft: Bool {
        switch self {
        case .store(_, let isSoft, _): return isSoft
        case .head: return false
        case .delete(_, let isSoft, _): return isSoft
        }
    }
}
public extension AtomObservation {
    static func stored(_ atom: Atom, isSoft: Bool = false, receivedAt: Date = Date()) -> AtomObservation {
        return .store(atom: atom, soft: isSoft, receivedAt: receivedAt)
    }
    
    static func deleted(_ atom: Atom, isSoft: Bool = false, receivedAt: Date = Date()) -> AtomObservation {
        return .delete(atom: atom, soft: isSoft, receivedAt: receivedAt)
    }
    
    static func head(receivedAtDate receivedAt: Date = Date()) -> AtomObservation {
        return .head(receivedAt: receivedAt)
    }
    
    init(_ atomEvent: AtomEvent) {
        let atom = atomEvent.atom
        switch atomEvent.type {
        case .delete: self = AtomObservation.deleted(atom)
        case .store: self = AtomObservation.stored(atom)
        }
    }
    
    var atom: Atom? {
        switch self {
        case .store(let atom, _, _): return atom
        case .delete(let atom, _, _): return atom
        case .head: return nil
        }
    }
    
    var receivedAt: Date {
        switch self {
        case .store(_, _, let date): return date
        case .delete(_, _, let date): return date
        case .head(let date): return date
        }
    }
    
    var isStore: Bool {
        guard case .store = self else { return false }
        return true
    }
    
    var isNonSoftStore: Bool {
        return !isSoft && isStore
    }
    
    var isHead: Bool {
        guard case .head = self else { return false }
        return true
    }
    
    var isDelete: Bool {
        guard case .delete = self else { return false }
        return true
    }
    
    func isSameType(as other: AtomObservation) -> Bool {
        switch (self, other) {
        case (.store, .store): return true
        case (.store, _): return false
            
        case (.head, .head): return true
        case (.head, _): return false
            
        case (.delete, .delete): return true
        case (.delete, _): return false
        }
    }
}
