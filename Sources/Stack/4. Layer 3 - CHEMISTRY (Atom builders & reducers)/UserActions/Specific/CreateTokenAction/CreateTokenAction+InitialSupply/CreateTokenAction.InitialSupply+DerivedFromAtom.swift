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

public extension CreateTokenAction.InitialSupply {
    
    enum DerivedFromAtom: Equatable {
        case fixedInitialSupply(PositiveSupply)
        
        /// Mutable Supply without information about any potential initial supply.
        ///
        /// Some mapper derived a CreateTokenAction with Mutable Supply from some Atom, but could not derive initial supply
        /// the reason for this is that we are unable to disambiguate between scenario 1 and scenario 2 below:
        /// scenario 1: CreateTokenAction of a token with mutable supply type, with an initial supply of `10`
        /// scenario 2: CreateTokenAction of a token with mutable supply type, without any initial supply (`0`), followed by a MintToken(`10`) action.
        /// Also the Mint action is in another ParticleGroup making the mapper tedious to implement
        case mutableSupply(initialSupplyInfoToBeFoundInAtomWithId: AtomIdentifier)
    }
}
