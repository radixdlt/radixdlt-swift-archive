//
//  TokenDefinitionParticle+Decodable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-08.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// MARK: - Decodable
public extension TokenDefinitionParticle {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        symbol = try container.decode(Symbol.self, forKey: .symbol)
        name = try container.decode(Name.self, forKey: .name)
        description = try container.decode(Description.self, forKey: .description)
        address = try container.decode(Address.self, forKey: .address)
        granularity = try container.decode(Granularity.self, forKey: .granularity)
        permissions = try container.decode(TokenPermissions.self, forKey: .permissions)
        iconUrl = URL(string: try container.decodeIfPresent(StringValue.self, forKey: .iconUrl)?.value)
        
    }
}

private extension URL {
    init?(string: String?) {
        guard let urlString = string else { return nil }
        self.init(string: urlString)
    }
}
