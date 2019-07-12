//
//  SupplyType.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum SupplyType: Int, Hashable {
    case fixed
    case mutable
}

public extension SupplyType {
    
    // MARK: - SupplyType From TokenPermissions
    init(tokenPermissions: TokenPermissions) {
        let mintPermission = tokenPermissions.mintPermission
        switch mintPermission {
        case .tokenCreationOnly, .none: self = .fixed
        case .tokenOwnerOnly, .all: self = .mutable
        }
    }
    
    // MARK: - SupplyType To TokenPermissions
    var tokenPermissions: TokenPermissions {
        switch self {
        case .fixed:
            return [
                .mint: .tokenCreationOnly,
                .burn: .none
            ]
            
        case .mutable:
            return [
                .mint: .tokenOwnerOnly,
                .burn: .tokenOwnerOnly
            ]
        }
    }
}
