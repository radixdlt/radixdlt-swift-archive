//
//  KeyPairConvertible+ECEIS+Decrypt.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension String.Encoding {
    static var `default`: String.Encoding {
        return .utf8
    }
}

public extension Signing {
    func decrypt(_ data: DataConvertible) throws -> Data {
        return try ECIES.decrypt(data: data, using: self)
    }
    
    func decryptAndDecode(_ data: DataConvertible, encoding: String.Encoding = .default) throws -> String {
        let encoded = try decrypt(data)
        
        // swiftlint:disable force_unwrap
        return String(data: encoded, encoding: encoding)!
    }
}
