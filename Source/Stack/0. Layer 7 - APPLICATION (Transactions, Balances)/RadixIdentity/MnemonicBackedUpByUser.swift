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
public typealias TouchType = NSTouch.TouchType
#elseif os(iOS) || os(tvOS) || os(watchOS)
import UIKit.UITouch
public typealias TouchType = UITouch.TouchType
#endif

/// Abstraction of an active user decision
public class UserInputAction {
    public init(touchType _: TouchType) {
        // require touch to initiate this abstraction of an active user decision
        #if DEBUG
        // Done! Use this to allow testing.
        #else
        guard Thread.isMainThread, touch else {
            incorrectImplementation("User actions occur on main thread")
        }
        #endif
    }
}

public class MnemonicBackedUpByUser: UserInputAction {}
