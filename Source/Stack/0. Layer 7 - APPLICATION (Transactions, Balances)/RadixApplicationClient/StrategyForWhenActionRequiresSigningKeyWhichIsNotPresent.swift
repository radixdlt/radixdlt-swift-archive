//
//  StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public enum StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent {
    case throwErrorDirectly
    case promptUserToProvideKey(PromptUserToProvideSigningKey)
}

public extension StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent {
    static func onResult(_ onResult: @escaping PromptUserToProvideSigningKey.OnResult) -> StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent {
        return .promptUserToProvideKey(PromptUserToProvideSigningKey(onResult: onResult))
    }
}

public struct PromptUserToProvideSigningKey {
    
    public enum SigningKeyProvidedByUser {
        case key(PrivateKey)
        case cancelled
        case timeout
    }
    
//    private let subject = PublishSubject<SigningKeyProvidedByUser>()
    public let timeout: TimeInterval?
//    public let result: Observable<SigningKeyProvidedByUser>
    private let onResult: (PromptUserToProvideSigningKey.SigningKeyProvidedByUser) -> Void
    public typealias OnResult = (PromptUserToProvideSigningKey.SigningKeyProvidedByUser) -> Void
    
    init(timeout: TimeInterval? = nil, onResult: @escaping OnResult) {
        self.timeout = timeout
        self.onResult = onResult
    }
    
    func gotResult(_ result: SigningKeyProvidedByUser) {
        onResult(result)
    }
}
