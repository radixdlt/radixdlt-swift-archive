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

public protocol TokenConvertible: TokenDefinitionReferencing {
    var symbol: Symbol { get }
    var name: Name { get }
    var tokenDefinedBy: Address { get }
    var granularity: Granularity { get }
    var description: Description { get }
    var iconUrl: URL? { get }
    var tokenSupplyType: SupplyType { get }
    var tokenPermissions: TokenPermissions? { get }
    var supply: Supply? { get }
}

// MARK: - Hashable Preparation
public extension TokenConvertible {
    func hash(into hasher: inout Hasher) {
        hasher.combine(tokenDefinitionReference)
    }
}

// MARK: - TokenDefinitionReferencing
public extension TokenConvertible {
    var tokenDefinitionReference: ResourceIdentifier {
        return ResourceIdentifier(address: tokenDefinedBy, symbol: symbol)
    }
}

// MARK: - Check Permissions
public extension TokenConvertible {
    func canBeMinted(by minter: Address) -> Bool {
        guard let permissions = tokenPermissions else {
            return false
        }
        return permissions.canBeMinted { self.address == minter }
    }
    
    func canBeBurned(by burner: Address) -> Bool {
        guard let permissions = tokenPermissions else {
            return false
        }
        return permissions.canBeBurned { self.address == burner }
    }
}
