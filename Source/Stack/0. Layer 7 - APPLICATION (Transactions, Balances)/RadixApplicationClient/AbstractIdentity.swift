//
//  AbstractIdentity.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public final class AbstractIdentity: Throwing, CustomStringConvertible {
    public typealias AccountSelector = ([Account]) -> Account
    public var alias: String?
    public private(set) var accounts: [Account]
    public init(accounts: [Account], alias: String? = nil) throws {
        if accounts.isEmpty {
            throw Error.mustContainAtLeastOneAccount
        }
        self.accounts = accounts
        self.alias = alias
    }
}

public extension AbstractIdentity {
    func selectAccount(_ selector: AccountSelector) -> Account {
        return selector(accounts)
    }
}

public extension AbstractIdentity {
    enum Error: Int, Swift.Error, Equatable {
        case mustContainAtLeastOneAccount
    }
}

// MARK: - CustomStringConvertible
public extension AbstractIdentity {
    var description: String {
        return """
        Accounts: #\(accounts.count)\(alias.ifPresent { ",\nalias: \($0)" })
        """
    }
}
