//
//  RadixApplicationClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt

public protocol RadixApplicationClient {
    
    /// The radix universe is an abstraction of some radix network
    /// , i.e. computer's running Radix `NodeRunner` (Radix Core) software.
    /// It holds an abstraction of a ledger and the configuration of the
    /// universe
    var universe: RadixUniverse { get }
   
    /// The identity is an abstraction of a holder of accounts (or zero). It also has
    /// an optional alias. It used to manage accounts.
    var identity: AbstractIdentity { get }
    
    /// The current active account (only account or by user selected account), from the set of accounts within the AbstractIdentity. If you provide it with a `magic`
    /// from a `UniverseConfig`, an address can be derived
    var activeAccount: Account { get }
    
    /// If there is an active account, using the `magic` in the config of the active universe, an address is derived.
    var addressOfActiveAccount: Address { get }
    
    /// Returns the native token found in the genesis atom, of the UniverseConfig
    var nativeTokenDefinition: TokenDefinition { get }
    
    func pull(address: Address) -> Disposable
    
    /// Returns a never ending hot observable of the state of a given address.
    /// If the given address is not currently being pulled this will pull for atoms in that
    /// address automatically until the observable is disposed.
    func applicationState<State>(ofType stateType: State.Type, at address: Address) -> Observable<State> where State: ApplicationState
    
    /// Returns a never ending hot observable of the actions performed at a given address.
    /// If the given address is not currently being pulled this will pull for atoms in that
    /// address automatically until the observable is disposed.
    func actions<ExecutedAction>(ofType actionType: ExecutedAction.Type, at address: Address) -> Observable<ExecutedAction>
    
    func execute(
        actions: [UserAction],
        ifNoSigningKeyPresent noKeyPresentStrategy: StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent
    ) -> ResultOfUserAction
}

internal extension RadixApplicationClient {
    func tokenDefinitions(at address: Address) -> Observable<TokenDefinitionsState> {
        return applicationState(ofType: TokenDefinitionsState.self, at: address)
    }
    
    func balanceReferences(at address: Address) -> Observable<TokenBalanceReferencesState> {
        return applicationState(ofType: TokenBalanceReferencesState.self, at: address)
    }
}

// MARK: - Public Methods using applicationState
public extension RadixApplicationClient {
    
    func tokenDefinition(identifier: ResourceIdentifier) -> Observable<TokenDefinition> {
        let address = identifier.address
        return tokenDefinitions(at: address).map {
            $0.tokenDefinition(identifier: identifier)
        }.ifNilReturnEmpty()
    }
    
    func balances(at address: Address) -> Observable<TokenBalances> {
        return Observable.combineLatest(
            self.balanceReferences(at: address),
            self.tokenDefinitions(at: address)
        ) {
            try TokenBalances(
                balanceReferencesState: $0,
                tokenDefinitionsState: $1
            )
        }
    }
    
    // MARK: - AccountBalance
    func balance(of tokenIdentifier: ResourceIdentifier, for address: Address) -> Observable<TokenBalance?> {
        return balances(at: address).map {
            $0.balance(of: tokenIdentifier)
        }
    }
    
    // MARK: - History of Executed Actions
    func tokenTransfers(toOrFrom address: Address) -> Observable<TransferTokenAction> {
        return actions(ofType: TransferTokenAction.self, at: address)
    }
    
    func messages(toOrFrom address: Address) -> Observable<DecryptedMessage> {
        return actions(ofType: DecryptedMessage.self, at: address)
    }
}

// MARK: - Perform Actions
public extension RadixApplicationClient {
    func create(
        token createTokenAction: CreateTokenAction,
        ifNoSigningKeyPresent noKeyPresentStrategy: StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent = .throwErrorDirectly
    ) -> ResultOfUserAction {
        return execute(action: createTokenAction, ifNoSigningKeyPresent: noKeyPresentStrategy)
    }
    
    func transfer(
        tokens transferTokensAction: TransferTokenAction,
        ifNoSigningKeyPresent noKeyPresentStrategy: StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent = .throwErrorDirectly
    ) -> ResultOfUserAction {
        return self.execute(action: transferTokensAction, ifNoSigningKeyPresent: noKeyPresentStrategy)
    }
    
    func send(
        message sendMessageAction: SendMessageAction,
        ifNoSigningKeyPresent noKeyPresentStrategy: StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent = .throwErrorDirectly
    ) -> ResultOfUserAction {
        return self.execute(action: sendMessageAction, ifNoSigningKeyPresent: noKeyPresentStrategy)
    }
    
    func execute(
        action: UserAction,
        ifNoSigningKeyPresent noKeyPresentStrategy: StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent = .throwErrorDirectly
    ) -> ResultOfUserAction {
        return execute(actions: [action], ifNoSigningKeyPresent: noKeyPresentStrategy)
    }
}

// MARK: - Send Message Convenience
public extension RadixApplicationClient {

    func sendPlainTextMessage(
        _ plainText: String,
        encoding: String.Encoding = .default,
        to recipient: Ownable,
        ifNoSigningKeyPresent noKeyPresentStrategy: StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent = .throwErrorDirectly
        ) -> ResultOfUserAction {
        let sendMessageAction = SendMessageAction.plainText(from: addressOfActiveAccount, to: recipient, text: plainText, encoding: encoding)
        return self.send(message: sendMessageAction, ifNoSigningKeyPresent: noKeyPresentStrategy)
    }
    
    func sendEncryptedMessage(
        _ textToEncrypt: String,
        encoding: String.Encoding = .default,
        to recipient: Ownable,
        canAlsoBeDecryptedBy extraDecryptors: [Ownable]? = nil,
        ifNoSigningKeyPresent noKeyPresentStrategy: StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent = .throwErrorDirectly
    ) -> ResultOfUserAction {
        
        let sendMessageAction = SendMessageAction.encryptedDecryptableBySenderAndRecipient(
            and: extraDecryptors,
            from: addressOfActiveAccount,
            to: recipient,
            text: textToEncrypt,
            encoding: encoding
        )
        
        return self.send(message: sendMessageAction, ifNoSigningKeyPresent: noKeyPresentStrategy)
    }
}

// MARK: - Default Implementation of functionality declared in protocol header
public extension RadixApplicationClient {
    
    var nativeTokenIdentifier: ResourceIdentifier {
        return nativeTokenDefinition.tokenDefinitionReference
    }
    
    var addressOfActiveAccount: Address {
        return activeAccount.addressFromMagic(magic)
    }
    
    func addressOf(account: Account) -> Address {
        return account.addressFromMagic(magic)
    }
    
}

// MARK: My Identity
public extension RadixApplicationClient {
    //    var myAddress: Address { return identity.address }
    
    /// Returns a hot observable of the latest state of token definitions at the user's address
    func myTokenDefinitions() -> Observable<TokenDefinitionsState> {
//        guard let myAddress = addressOfActiveAccount else { return Observable.empty() }
        return tokenDefinitions(at: addressOfActiveAccount)
    }
    
    func myTokenTransfers() -> Observable<TransferTokenAction> {
//        guard let myAddress = addressOfActiveAccount else { return Observable.empty() }
        return tokenTransfers(toOrFrom: addressOfActiveAccount)
    }
    
    func myBalances() -> Observable<TokenBalances> {
        return balances(at: addressOfActiveAccount)
    }
    
    func myBalance(of tokenIdentifier: ResourceIdentifier) -> Observable<TokenBalance?> {
        return balance(of: tokenIdentifier, for: addressOfActiveAccount)
    }
    
    func myBalanceOfNativeTokens() -> Observable<TokenBalance?> {
        return myBalance(of: nativeTokenIdentifier)
    }
    
    func myBalanceOfNativeTokensOrZero() -> Observable<TokenBalance> {
        return myBalanceOfNativeTokens()
            .replaceNilWith(TokenBalance.zero(token: nativeTokenDefinition, ownedBy: addressOfActiveAccount))
    }
    
    func myMessages() -> Observable<DecryptedMessage> {
//        guard let myAddress = addressOfActiveAccount else { return Observable.empty() }
        return messages(toOrFrom: addressOfActiveAccount)
    }
    
    func pull() -> Disposable {
        return pull(address: addressOfActiveAccount)
    }
    
}

public extension RadixApplicationClient {
    
    func balanceOfNativeTokensOrZero(for address: Address) -> Observable<TokenBalance> {
        return balance(of: nativeTokenIdentifier, for: address)
            .replaceNilWith(TokenBalance.zero(token: nativeTokenDefinition, ownedBy: address))
    }
    
    var universeConfig: UniverseConfig {
        return universe.config
    }
    
    var magic: Magic {
        return universeConfig.magic
    }
    
    var nativeTokenDefinition: TokenDefinition {
        return universe.nativeTokenDefinition
    }
    
}

internal extension RadixApplicationClient {
    var atomPuller: AtomPuller {
        return universe.atomPuller
    }
    
    var atomStore: AtomStore {
        return universe.atomStore
    }
}

public extension RadixApplicationClient {
    
    @discardableResult
    func changeAccount(accountSelector: AbstractIdentity.AccountSelector) -> Account? {
        return identity.selectAccount(accountSelector)
    }
}

public extension RadixApplicationClient {
    func createToken(
        name: Name,
        symbol: Symbol,
        description: Description,
        supply initialSupplyType: CreateTokenAction.InitialSupply,
        granularity: Granularity = .default,
        ifNoSigningKeyPresent: StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent = .throwErrorDirectly
    ) throws -> ResultOfUserAction {
        
        let createTokenAction = try CreateTokenAction(
            creator: addressOfActiveAccount,
            name: name,
            symbol: symbol,
            description: description,
            supply: initialSupplyType,
            granularity: granularity
        )
        
        print("Woho creating token...?")
        
        return self.create(
            token: createTokenAction,
            ifNoSigningKeyPresent: ifNoSigningKeyPresent
        )
    }
}
