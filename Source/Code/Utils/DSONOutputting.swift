//
//  DSONOutputSpecifying.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol DSONOutputSpecifying {
    var output: DSONOutput { get }
}

public extension DSONOutputSpecifying {
    func allowsOutput(of other: DSONOutput) -> Bool {
        return output.allowsOutput(of: other)
    }
}
