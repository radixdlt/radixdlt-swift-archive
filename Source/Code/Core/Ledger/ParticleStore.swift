//
//  ParticleStore.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol ParticleStore {
    func particles(for address: Address) -> Observable<SpunParticle>
}
