//
//  MnemonicBackedUpByUser.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

#if os(OSX)
import AppKit.NSTouch
public typealias TouchByUser = NSTouch
#elseif os(iOS) || os(tvOS) || os(watchOS)
import UIKit.UITouch
public typealias TouchByUser = UITouch
#endif

/// Abstraction of an active user decision
public class UserInputAction: Throwing {
    
    #if DEBUG
    // Done! Use this to allow testing.
    internal init() {}
    #endif
    
    public init(touchByUser: TouchByUser) throws {
        // require touch to initiate this abstraction of an active user decision
        
        guard Thread.isMainThread else {
            throw Error.touchDidNotOccurOnMainThreadWhichIsRequired
        }
        
        #if os(OSX)
        guard touchByUser.device != nil else {
            throw Error.touchDidNotOriginateFromAnyDeviceWhichIsRequired
        }
        #elseif os(iOS) || os(tvOS) || os(watchOS)
        guard touchByUser.view != nil else {
            throw Error.touchDidNotOriginateFromAnyViewWhichIsRequired
        }
        #endif
    }
}

public extension UserInputAction {
    enum Error: Swift.Error, Equatable {
        case touchDidNotOccurOnMainThreadWhichIsRequired
        
        #if os(OSX)
        case touchDidNotOriginateFromAnyDeviceWhichIsRequired
        #elseif os(iOS) || os(tvOS) || os(watchOS)
        case touchDidNotOriginateFromAnyViewWhichIsRequired
        #endif
        
    }
}

public class MnemonicBackedUpByUser: UserInputAction {
    #if DEBUG
    // Done! Use this to allow testing.
    internal init(mnemonic _: Mnemonic) {
        super.init()
    }
    #endif
    
    public init(mnemonic _: Mnemonic, touchByUser: TouchByUser) throws {
        try super.init(touchByUser: touchByUser)
    }
}
