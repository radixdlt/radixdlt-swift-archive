//
//  RequestIdGenerator.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public final class RequestIdGenerator {
    
    public static let shared = RequestIdGenerator()
    
    private var id: Int = 0
    private init() {}
}

// MARK: - Public
public extension RequestIdGenerator {
    static func nextId() -> Int {
        return shared.nextId()
    }
}

// MARK: - Private
private extension RequestIdGenerator {
    func nextId() -> Int {
        defer { id += 1 }
        return id
    }
}
