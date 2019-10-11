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
import Combine

public enum Account: Hashable, AtomSigning, SigningRequesting, PublicKeyOwner {
    case privateKeyPresent(KeyPair)
    case privateKeyNotPresent(PublicKey)
}

public extension Account {
    var publicKey: PublicKey {
        switch self {
        case .privateKeyPresent(let publicKeyOwner): return publicKeyOwner.publicKey
        case .privateKeyNotPresent(let publicKeyOwner): return publicKeyOwner.publicKey
        }
    }
    
    var privateKey: PrivateKey? {
        switch self {
        case .privateKeyPresent(let privateKeyOwner): return privateKeyOwner.privateKey
        case .privateKeyNotPresent: return nil
        }
    }
    
    var privateKeyForSigning: CombineSingle<PrivateKey> {
        if let privateKey = privateKey {
            return CombineSingle.just(privateKey)
        } else {
            return requestSignableKeyFromUser(matchingPublicKey: publicKey)
        }
    }
}

public extension Account {
    func addressFromMagic(_ magic: Magic) -> Address {
        return Address(magic: magic, publicKey: publicKey)
    }
}

public extension Account {
    func requestSignableKeyFromUser(matchingPublicKey: PublicKey) -> CombineSingle<PrivateKey> {
        implementMe()
    }
}

public extension Account {
    init(privateKey: PrivateKey) {
        let keyPair = KeyPair(private: privateKey)
        self = .privateKeyPresent(keyPair)
    }
}
