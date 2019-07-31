//
//  AbstractIdentity.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public final class AbstractIdentity: CustomStringConvertible {
    public typealias AccountSelector = (NonEmptyArray<Account>) -> Account
    
    public var alias: String?
    public private(set) var accounts: NonEmptyArray<Account>
    public private(set) var activeAccount: Account
    
    public init(
        accounts: NonEmptyArray<Account>,
        alias: String? = nil,
        selectInitialActiveAccount: AccountSelector = { $0.first }
    ) throws {
        
        self.accounts = accounts
        self.alias = alias
        self.activeAccount = selectInitialActiveAccount(accounts)
    }
}

public extension AbstractIdentity {
    
    @discardableResult
    func selectAccount(_ selector: AccountSelector) -> Account {
        return selector(accounts)
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
