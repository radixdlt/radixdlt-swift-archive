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
import RxSwift

// MARK: - Presets
public extension Array where Element == AnyAtomToExecutedActionMapper {
    static func atomToActionMappers(activeAccount: Observable<Account>) -> [AnyAtomToExecutedActionMapper] {
        return [
            AnyAtomToExecutedActionMapper(any: DefaultAtomToSendMessageActionMapper(activeAccount: activeAccount) ),

            // `AtomToCreateTokenMapper` ought to come before `AtomToMintTokenMapper` so that order of actions
            // in Transaction is `createToken` then `mint` for tokens with mutable initial supply.
            AnyAtomToExecutedActionMapper(any: DefaultAtomToCreateTokenMapper()),
            
            AnyAtomToExecutedActionMapper(any: DefaultAtomToTokenTransferMapper()),
            AnyAtomToExecutedActionMapper(any: DefaultAtomToBurnTokenMapper()),
            AnyAtomToExecutedActionMapper(any: DefaultAtomToMintTokenMapper()),
            AnyAtomToExecutedActionMapper(any: DefaultAtomToUniqueIdMapper())
        ]
    }
}

public extension Array where Element == AnyParticleReducer {
    static var `default`: [AnyParticleReducer] {
        return [
            AnyParticleReducer(TokenBalanceReferencesReducer()),
            AnyParticleReducer(TokenDefinitionsReducer())
        ]
    }
}

public extension Array where Element == AnyStatefulActionToParticleGroupsMapper {
    static var `default`: [AnyStatefulActionToParticleGroupsMapper] {
        return [
            AnyStatefulActionToParticleGroupsMapper(DefaultMintTokensActionToParticleGroupsMapper()),
            AnyStatefulActionToParticleGroupsMapper(DefaultBurnTokensActionToParticleGroupsMapper()),
            AnyStatefulActionToParticleGroupsMapper(DefaultTransferTokensActionToParticleGroupsMapper()),
            AnyStatefulActionToParticleGroupsMapper(DefaultPutUniqueActionToParticleGroupsMapper()),
            AnyStatefulActionToParticleGroupsMapper(DefaultCreateTokenActionToParticleGroupsMapper())
        ]
    }
}

public extension Array where Element == AnyStatelessActionToParticleGroupsMapper {
    static var `default`: [AnyStatelessActionToParticleGroupsMapper] {
        return [
            AnyStatelessActionToParticleGroupsMapper(DefaultSendMessageActionToParticleGroupsMapper())
        ]
    }
}
