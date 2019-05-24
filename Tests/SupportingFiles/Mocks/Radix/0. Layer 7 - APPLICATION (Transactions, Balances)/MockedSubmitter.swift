//
//  MockedSubmitter.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-05-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK

struct MockedSubmitter: NodeInteractingSubmit {
    let nodeSubmitter: NodeInteractionSubmitting
    init(mockedSubmitter: NodeInteractionSubmitting = MockedNodeSubmitting()) {
        self.nodeSubmitter = mockedSubmitter
    }
}
