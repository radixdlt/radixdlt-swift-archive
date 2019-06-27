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
        
        if
            let fetchAtomAction = action as? FetchAtomsAction,
            case .observation((let uuid, let address), let fromNode, let atomObservation) = fetchAtomAction
        {
           atomStore.store(atomObservation: atomObservation, address: address, notifyListeners: .notifyOnAtomUpdate)
        }

        if
            let submitAtomAction = action as? SubmitAtomAction,
            case .statusOf((let uuid, let atom), let sentToNode, let atomStatusNotification) = submitAtomAction
        {
            if atomStatusNotification.atomStatus == AtomStatus.stored {
                atom.addresses().forEach { addressInAtom in
                    func store(atomObservation: AtomObservation) {
                        atomStore.store(atomObservation: atomObservation, address: addressInAtom, notifyListeners: .dontNotify)
                    }
                    store(atomObservation: .stored(atom, isSoft: true))
                    store(atomObservation: .head())
                }
            }
        }

    }
    
}
