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
