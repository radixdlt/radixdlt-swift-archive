//
//  AbstractIdentity.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift
import BitcoinKit

public final class AbstractIdentity: CustomStringConvertible {
    public typealias AccountSelector = (NonEmptyArray<Account>) -> Account
    
    public var alias: String?
    public private(set) var accounts: NonEmptyArray<Account>
    public private(set) var activeAccount: Account
    
    public init(
        accounts: NonEmptyArray<Account>,
        alias: String? = nil,
        selectInitialActiveAccount: AccountSelector = { $0.first }
    ) {
        self.accounts = accounts
        self.alias = alias
        self.activeAccount = selectInitialActiveAccount(accounts)
    }
}

public extension AbstractIdentity {
    static func new(
        alias: String? = nil,
        mnemonicGenerator: Mnemonic.Generator = .default,
        backedUpMneumonic: @escaping (Mnemonic) -> MnemonicBackedUpByUser
    ) -> Single<AbstractIdentity> {
        
        return Single<AbstractIdentity>.create { single in
            
            do {
                let mnemonic = try mnemonicGenerator.generate()
                
                // async
                _ = backedUpMneumonic(mnemonic)
           
                // TODO: replace BTC network with Radix one...
                let wallet = BitcoinKit.HDWallet(seed: mnemonic.seed, network: BitcoinKit.Network.testnetBTC)
                
                let privateKeyBicoinKit = try wallet.privateKey(index: 0)
                
                let privateKey = try PrivateKey(data: privateKeyBicoinKit.data)
                
                let account = Account(privateKey: privateKey)
                
                let identity = AbstractIdentity(accounts: [account], alias: alias)
                
                single(.success(identity))
            } catch {
                single(.error(error))
            }
            
            return Disposables.create()
        }
    }
}

internal extension AbstractIdentity {
    
    #if DEBUG
    static func newSkippingBackup(alias: String? = nil) -> Single<AbstractIdentity> {
        return new(alias: alias, backedUpMneumonic: { MnemonicBackedUpByUser(mnemonic: $0) })
    }
    
    convenience init(alias: String? = nil) {
        let identitySingle = AbstractIdentity.newSkippingBackup(alias: alias).toBlocking(timeout: 1)
        do {
            guard let identity = try identitySingle.first() else {
                incorrectImplementation("Should always be able to create identity")
            }
            self.init(accounts: identity.accounts, alias: alias)
        } catch { unexpectedlyMissedToCatch(error: error) }
    }
    #endif
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
