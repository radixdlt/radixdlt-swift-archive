//
//  PersistentChannel.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol PersistentChannel {
    func sendMessage(_ message: String)
    var messages: Observable<String> { get }
}
