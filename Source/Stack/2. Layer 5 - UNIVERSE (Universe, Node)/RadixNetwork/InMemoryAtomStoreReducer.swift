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

public final class InMemoryAtomStoreReducer: Reducer {
    public typealias Action = NodeAction
    
    private let atomStore: InMemoryAtomStore
    public init(atomStore: InMemoryAtomStore) {
        self.atomStore = atomStore
    }
}

public extension InMemoryAtomStoreReducer {
    
    func reduce(action: Action) {
        
        if let fetchAtomActionObservation = action as? FetchAtomsActionObservation {
            let atomObservation = fetchAtomActionObservation.atomObservation
            let address = fetchAtomActionObservation.address
            atomStore.store(atomObservation: atomObservation, address: address, notifyListenerMode: .notifyOnAtomUpdateAndSync)
        }

        if let submitAtomActionStatus = action as? SubmitAtomActionStatus {
            let atomStatusEvent = submitAtomActionStatus.statusEvent
            let atom = submitAtomActionStatus.atom
            if atomStatusEvent == .stored {
                atom.addresses().forEach { addressInAtom in
                    func store(atomObservation: AtomObservation) {
                        atomStore.store(atomObservation: atomObservation, address: addressInAtom, notifyListenerMode: .notifyOnAtomUpdateAndSync)
                    }
                    store(atomObservation: .stored(atom.wrappedAtom.wrappedAtom, isSoft: true))
                    store(atomObservation: .head())
                }
            }
        }

    }
    
}
