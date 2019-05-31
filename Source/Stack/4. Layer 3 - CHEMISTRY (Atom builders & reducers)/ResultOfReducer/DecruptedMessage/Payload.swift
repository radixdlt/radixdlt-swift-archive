//
//  Payload.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-31.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Payload {
    public let metaData: [MetaDataKey: Any]
    public let payload: Data
    private let mode: Mode
    
    public init(payload: Data, metaData: [MetaDataKey: Any], mode: Mode) {
        self.payload = payload
        self.mode = mode
        
        var metaData = metaData
        metaData[MetaDataKey.encrypted] = mode.isEncrypted
        self.metaData = metaData
    }
}

public extension Payload {
    
    enum Mode {
        case encryption(encryptor: Encryptor)
        case noEncryption
    }
    
    var isEncrypted: Bool {
        guard
            let isEncrypted = metaData[MetaDataKey.encrypted] as? Bool
            else {
                return false
        }
        return isEncrypted
    }
}

public extension Payload.Mode {
    var isEncrypted: Bool {
        return encryptor != nil
    }
    
    var encryptor: Encryptor? {
        switch self {
        case .noEncryption: return nil
        case .encryption(let encryptor): return encryptor
        }
    }
}

public extension Payload {
    var encryptor: Encryptor? {
        return mode.encryptor
    }
}

public extension Payload {
    init(payload: Data, metaData: [MetaDataKey: Any], readers: NonEmptySet<PublicKey>) throws {
        
        let encryptor = try Encryptor(sharedKey: KeyPair(), readers: readers.elements)
        
        self.init(payload: payload, metaData: metaData, mode: .encryption(encryptor: encryptor))
    }
}
