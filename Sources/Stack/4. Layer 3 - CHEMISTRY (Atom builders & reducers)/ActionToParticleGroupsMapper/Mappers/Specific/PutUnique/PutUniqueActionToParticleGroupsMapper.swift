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

// MARK: PutUniqueActionToParticleGroupsMapper

// swiftlint:disable opening_brace

public protocol PutUniqueActionToParticleGroupsMapper: UniquelyIdentifiedUserActionToParticleGroupsMapper
    where
    Action == PutUniqueIdAction,
    SpecificActionError == PutUniqueIdError
{}

// swiftlint:enable opening_brace

// MARK: Default Implementation
public extension PutUniqueActionToParticleGroupsMapper {
    func mapError(_ putUniqueIdError: PutUniqueIdError, action putUniqueIdAction: PutUniqueIdAction) -> ActionsToAtomError {
        ActionsToAtomError.putUniqueIdActionError(putUniqueIdError, action: putUniqueIdAction)
    }
    
    func particleGroups(
        for action: PutUniqueIdAction,
        upParticles: [AnyUpParticle],
        addressOfActiveAccount: Address
    ) throws -> Throws<ParticleGroups, PutUniqueIdError> {
        do {
            try validateInputMappingUniqueActionError(action: action, upParticles: upParticles, addressOfActiveAccount: addressOfActiveAccount)
            
            let uniqueParticle = UniqueParticle(address: action.uniqueMaker, string: action.string)
            let rriParticle = ResourceIdentifierParticle(resourceIdentifier: uniqueParticle.identifier)
            
            let spunParticles = [
                rriParticle.withSpin(.down),
                uniqueParticle.withSpin(.up)
            ]
            
            let particleGroup = try spunParticles.wrapInGroup()
            
            return [particleGroup]
        } catch let putUniqueIdError as PutUniqueIdError {
            throw putUniqueIdError
        } catch {
            unexpectedlyMissedToCatch(error: error)
        }
    }
}
