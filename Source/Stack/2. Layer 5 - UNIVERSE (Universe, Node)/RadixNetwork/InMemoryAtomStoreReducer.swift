//
//  InMemoryAtomStoreReducer.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
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
