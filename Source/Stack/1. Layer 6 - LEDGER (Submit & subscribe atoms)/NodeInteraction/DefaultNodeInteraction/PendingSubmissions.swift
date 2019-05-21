//
//  PendingSubmissions.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public typealias AtomHashId = EUID

public struct PendingSubmissions: DictionaryConvertibleMutable, ExpressibleByDictionaryLiteral {
    public typealias Key = AtomHashId
    public typealias Value = Observable<AtomSubscriptionUpdateSubmitAndSubscribe>
    public typealias Map = [Key: Value]
    public var dictionary: Map
    public init(dictionary: Map) {
        self.dictionary = dictionary
    }
}
