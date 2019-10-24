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

public enum TypedTokenDefinition {
    case mutableSupplyTokenDefinitionParticle(MutableSupplyTokenDefinitionParticle)
    case fixedSupplyTokenDefinitionParticle(FixedSupplyTokenDefinitionParticle)
}

public extension TypedTokenDefinition {
    var tokenDefinition: TokenDefinition {
        switch self {
        case .fixedSupplyTokenDefinitionParticle(let fixedSupplyParticle):
            return TokenDefinition(tokenConvertible: fixedSupplyParticle)
        case .mutableSupplyTokenDefinitionParticle(let mutableSupplyParticle):
            return TokenDefinition(tokenConvertible: mutableSupplyParticle)
        }
    }
}

public extension SpunParticlesOwner {
    func typedTokenDefinition(matchingIdentifier rri: ResourceIdentifier) -> TypedTokenDefinition? {
        
        let maybeMutableSupplyTokenDefinitionParticle = self.firstMutableSupplyTokenDefinitionParticle(matchingIdentifier: rri)
        
        let maybeFixedSupplyTokenDefinitionsParticle = self.firstFixedSupplyTokenDefinitionParticle(matchingIdentifier: rri)
        
        switch (maybeMutableSupplyTokenDefinitionParticle, maybeFixedSupplyTokenDefinitionsParticle) {
        case (.some(let mutableSupplyTokenDefinitionParticle), .none):
            return .mutableSupplyTokenDefinitionParticle(mutableSupplyTokenDefinitionParticle)
        case (.none, .some(let fixedSupplyTokenDefinitionsParticle)):
            return .fixedSupplyTokenDefinitionParticle(fixedSupplyTokenDefinitionsParticle)
        case (.none, .none):
            return nil
        case (.some, .some):
            incorrectImplementation("Not possible to have both a FixedSupplyTokenDefinition and a MutableSuppleTokenDefinition for the same RRI: \(rri)")
        }
    }
}
