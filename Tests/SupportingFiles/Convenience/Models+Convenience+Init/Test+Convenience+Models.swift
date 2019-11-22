//
// MIT License
//
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation
@testable import RadixSDK

extension String {
    static var randomSuitableForSymbol: String {
        String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(14))
    }
}

extension Symbol {
    static var random: Symbol {
        .init(validated: String.randomSuitableForSymbol)
    }
}

extension Address {
    static var irrelevant: Address {
        return Address(magic: .irrelevant, publicKey: .irrelevant)
    }
    
    static func irrelevant(index: Int) -> Address {
        let privateKeyScalar: PrivateKey.Scalar = PrivateKey.Scalar(exactly: index)!
        let privateKey: PrivateKey = try! .init(scalar: privateKeyScalar)
        return Address(magic: .irrelevant, publicKey: PublicKey(private: privateKey))
    }
}

extension PublicKey {
    static var irrelevant: PublicKey {
        return PublicKey(private: PrivateKey())
    }
    
}

extension Magic {
    static var irrelevant: Magic {
        return 1
    }
}

extension String {
    static var irrelevant: String {
        return "irrelevant"
    }
}

extension Symbol {
    static var irrelevant: Symbol {
        return "IRR"
    }
}

extension Name {
    static var irrelevant: Name {
        return "Irrelevant"
    }
}

extension Description {
    static var irrelevant: Description {
        return "Irrelevant description"
    }
}

extension PositiveAmount {
    static var irrelevant: PositiveAmount { return 42 }
}

extension Data {
    static var irrelevant: Data {
        return .empty
    }
}

extension CreateTokenAction {
    // Need to be static method instead of init in order to disambiguate with designated initiliazer
    static func new(
        creator: Address = .irrelevant,
        name: Name = .irrelevant,
        symbol: Symbol = .random,
        description: Description = .irrelevant,
        supply supplyTypeDefinition: CreateTokenAction.InitialSupply.SupplyTypeDefinition = .mutableZeroSupply,
        iconUrl: URL? = nil,
        granularity: Granularity = .default,
        tokenPermissions: TokenPermissions = .mutableSupplyToken
    ) throws -> CreateTokenAction {
    
        return try self.init(
            creator: creator,
            name: name,
            symbol: symbol,
            description: description,
            supply: supplyTypeDefinition,
            iconUrl: iconUrl,
            granularity: granularity,
            permissions: tokenPermissions
        )
    }
}
