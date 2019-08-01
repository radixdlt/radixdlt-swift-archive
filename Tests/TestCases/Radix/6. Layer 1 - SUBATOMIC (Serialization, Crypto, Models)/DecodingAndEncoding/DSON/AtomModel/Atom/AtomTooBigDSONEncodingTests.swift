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

@testable import RadixSDK
import XCTest

class AtomTooBigDSONEncodingTests: XCTestCase {
    
    func testDsonEncodingAtomTooBig() {
        // GIVEN
        // An atom with 1000 particles
        let atom = Atom(
            particleGroups: [ParticleGroup(spunParticles: oneThousandParticles)]
        )
        
        XCTAssertThrowsSpecificError(
            // WHEN
            // I try DSON encode the big Atom
            try atom.toDSON(),
            // THEN
            Atom.Error.tooManyBytes(expectedAtMost: irrelevant(), butGot: irrelevant()),
            "An error saying the atom is too big should be thrown"
        )
        
    }
}

private let oneThousandParticles = [AnySpunParticle](repeating: spunTokenParticle, count: 1000)
private let spunTokenParticle = AnySpunParticle(
    spin: .up,
    particle: UnallocatedTokensParticle(
        amount: 1337,
        tokenDefinitionReference: "/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/XRD"
    )
)

func irrelevant<Integer>() -> Integer where Integer: ExpressibleByIntegerLiteral & _ExpressibleByBuiltinIntegerLiteral {
    return Integer.init(integerLiteral: 0)
}
