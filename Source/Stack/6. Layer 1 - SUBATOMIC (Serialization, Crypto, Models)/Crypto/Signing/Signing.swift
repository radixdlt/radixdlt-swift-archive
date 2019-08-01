//
//  Signing.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol SigningRequesting {
    var privateKeyForSigning: Single<PrivateKey> { get }
}

public protocol Signing: SigningRequesting {
    var privateKey: PrivateKey { get }
}

public extension Signing {
    var privateKeyForSigning: Single<PrivateKey> {
        return Single.just(privateKey)
    }
}
