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

// MARK: AtomToUniqueIdMapper
public protocol AtomToUniqueIdMapper: AtomToSpecificExecutedActionMapper where SpecificExecutedAction == PutUniqueIdAction {}

// MARK: DefaultAtomToUniqueIdMapper
public final class DefaultAtomToUniqueIdMapper: AtomToUniqueIdMapper {
    public init() {}
}

public extension DefaultAtomToUniqueIdMapper {
    
    typealias SpecificExecutedAction = PutUniqueIdAction
    
    func mapAtomToAction(_ atom: Atom) -> Observable<PutUniqueIdAction?> {
        guard atom.containsAnyUniqueParticle(spin: .up) else { return .just(nil) }
        
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
        
        guard !uniqueActions.isEmpty else { return .just(nil) }
        return Observable.from(uniqueActions)
    }
}
