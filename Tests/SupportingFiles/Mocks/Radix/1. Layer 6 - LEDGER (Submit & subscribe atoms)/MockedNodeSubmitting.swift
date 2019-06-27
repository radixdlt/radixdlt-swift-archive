//
//  MockedNodeSubmitting.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-05-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import RxSwift

struct MockedNodeSubmitting: NodeInteractionSubmitting {
    func submit(atom: SignedAtom) -> CompletableWanted {
        abstract()
    }
}
