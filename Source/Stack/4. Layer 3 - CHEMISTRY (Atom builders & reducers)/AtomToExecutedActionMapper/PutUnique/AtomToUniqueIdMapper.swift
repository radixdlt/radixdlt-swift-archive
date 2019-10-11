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
import Combine

// MARK: AtomToUniqueIdMapper
public protocol AtomToUniqueIdMapper: AtomToSpecificExecutedActionMapper where SpecificExecutedAction == PutUniqueIdAction {}

public extension AtomToUniqueIdMapper {
    
    func mapAtomToActions(_ atom: Atom) -> CombineObservable<[PutUniqueIdAction]> {
        guard atom.containsAnyUniqueParticle(spin: .up) else { return .just([]) }
        
        var uniqueActions = [PutUniqueIdAction]()
        for particleGroup in atom {
            guard
                let rriParticle = particleGroup.firstRRIParticle(spin: .down),
                case let rri = rriParticle.resourceIdentifier,
                let uniqueParticle = particleGroup.firstUniqueParticle(matchingIdentifier: rri, spin: .up)
                else { continue }
            
            uniqueActions.append(
                PutUniqueIdAction(uniqueParticle: uniqueParticle)
            )
        }
        
        return CombineObservable.just(uniqueActions)
    }
}

// MARK: DefaultAtomToUniqueIdMapper
public struct DefaultAtomToUniqueIdMapper: AtomToUniqueIdMapper {
    public typealias SpecificExecutedAction = PutUniqueIdAction
}
