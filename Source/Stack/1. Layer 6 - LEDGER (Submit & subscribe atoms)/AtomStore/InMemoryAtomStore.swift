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
import Entwine

public final class InMemoryAtomStore: AtomStore {
    
    private var stagedAtoms         = [UUID: Atom]()
    private var atoms               = [Atom: AtomObservation]()
    
    private var particleIndex       = [AnyParticle: [Spin: Set<Atom>]]()
    
    private var synced              = [Address: Bool]()
    
    private var atomUpdateListeners: ListenerOf<AtomObservation> = .init()
    private var syncListeners: ListenerOf<Date> = .init()
    
    public init(
        genesisAtoms: [Atom] = []
    ) {
        
        // Store genesis atoms
        genesisAtoms.forEach { atom in
            atom.allAddresses.forEach {
                let atomObservation = AtomObservation.stored(atom)
                self.store(
                    atomObservation: atomObservation,
                    address: $0,
                    // TODO change `notifyListenerMode` to `.donʼtNotify`?
                    notifyListenerMode: .notifyOnAtomUpdateAndSync
                )
            }
            atom.allAddresses.forEach {
                self.store(atomObservation: AtomObservation.headNow(), address: $0, notifyListenerMode: .notifyOnAtomUpdateAndSync)
            }
        }
    }
}

// MARK: - Public
public extension InMemoryAtomStore {
    
    func onSync(address: Address) -> AnyPublisher<Date, Never> {
        if let existingListenerAtAddress = syncListeners.listener(of: address) {
            return existingListenerAtAddress.eraseToAnyPublisher()
        } else {
            let newListener = ReplaySubject<Date, Never>.unlimitedBufferSize()
            syncListeners.addListener(newListener, of: address)
            defer {
                if synced.valueForKey(key: address, ifAbsent: { false }) {
                    newListener.send(Date())
                }
            }
            return newListener.eraseToAnyPublisher()
        }
    }
    
    func atomObservations(of address: Address) -> AnyPublisher<AtomObservation, Never> {
        
        if let existingListenerAtAddress = atomUpdateListeners.listener(of: address) {
            return existingListenerAtAddress.eraseToAnyPublisher()
        } else {
            let newListener = ReplaySubject<AtomObservation, Never>.unlimitedBufferSize()
            atomUpdateListeners.addListener(newListener, of: address)
            
            // Replay history
            atoms.filter {
                $0.value.isStore && $0.key.allAddresses.contains(address)
            }.compactMap {
                $0.value
            }.forEach { newListener.send($0) }
            
            return newListener.eraseToAnyPublisher()
        }
    }
    
    func upParticles(at address: Address) -> [AnyUpParticle] {
        return particleIndex.filter {
            // swiftlint:disable:next force_try
            let shardables = try! $0.key.someParticle.shardables()
            guard shardables?.contains(address) == true else { return false }
            
            var spinParticleIndex = $0.value
            let hasDown = spinParticleIndex.valueForKey(key: .down, ifAbsent: { Set() }).contains(where: { atoms[$0]?.isStore == true })
            if hasDown { return false }
            
            let uppingAtoms = spinParticleIndex.valueForKey(key: .up, ifAbsent: { Set() })
            return uppingAtoms.contains(where: { atom in
                guard let atomObservation = self.atoms.valueFor(key: atom) else { return false }
                return atomObservation.isStore
            })
        }
        .map { $0.key }
            .removeDuplicates() // remove any duplicates
            .upParticles()
    }
    
    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func store(atomObservation: AtomObservation, address: Address, notifyListenerMode: AtomNotificationMode) {
        if let atom = atomObservation.atom, let currentAtomObservation = atoms[atom], atomObservation.ignoringDateIsEqual(to: currentAtomObservation) {
            print("⚠️ Ignored atom observation, already existing")
            return
        }
        
        let areAtomsInSync = atomObservation.isHead
        synced[address] = areAtomsInSync
        defer {
            if areAtomsInSync, notifyListenerMode.shouldNotifyOnSync {
                syncListeners.notifyLister(of: address, about: Date())
            }
        }
        
        guard let atom = atomObservation.atom else {
            if notifyListenerMode.shouldNotifyOnAtomUpdate {
                atomUpdateListeners.notifyLister(of: address, about: atomObservation)
            }
            return
        }
        
        // If a new hard observed atoms conflicts with a previously stored atom,
        // stored atom must be deleted
        if atomObservation.isNonSoftStore {
            spunParticlesInAtomLoop: for spunParticle in atom.spunParticles {
                guard
                    let spinParticleIndex = particleIndex.valueFor(key: AnyParticle(spunParticle: spunParticle)),
                    let atomsInIndex = spinParticleIndex.valueFor(key: spunParticle.spin)
                    else
                { continue spunParticlesInAtomLoop }
                
                atomsInIndexLoop: for atomInIndex in atomsInIndex {
                    guard atomInIndex != atom, let oldObservation = atoms[atomInIndex], oldObservation.isStore else {
                        continue atomsInIndexLoop
                    }
                    softDeleteDependentsOf(atom: atomInIndex)
                    atoms[atomInIndex] = AtomObservation.deleted(atomInIndex, isSoft: true)
                }
            }
            
        }
        
        let includeAtom: Bool
        let isSoftToHard: Bool
        if let currentAtomObservation = atoms[atom] {
            // Soft observation should not be able to update a hard state
            // Only update if type changes
            includeAtom = (!atomObservation.isSoft || currentAtomObservation.isSoft) && !atomObservation.isSameType(as: currentAtomObservation)
            isSoftToHard = currentAtomObservation.isSoft && !atomObservation.isSoft
            
        } else {
            includeAtom = atomObservation.isStore
            isSoftToHard = false
            atom.spunParticles.forEach { spunParticle in
                let key = AnyParticle(spunParticle: spunParticle)
                let spinParticleIndex = particleIndex.valueForKey(key: key) { [Spin: Set<Atom>]() }
                particleIndex[key] = spinParticleIndex.merging([spunParticle.spin: [atom].asSet], uniquingKeysWith: { $0.union($1) })
            }
        }
        
        if atomObservation.isDelete && includeAtom {
            softDeleteDependentsOf(atom: atom)
        }
        
        if includeAtom || isSoftToHard {
            atoms[atom] = atomObservation
        }
        
        if includeAtom, notifyListenerMode.shouldNotifyOnAtomUpdate {
            atom.allAddresses.forEach {
                atomUpdateListeners.notifyLister(of: $0, about: atomObservation)
            }
        }
        
    }
}

// MARK: Private
private extension InMemoryAtomStore {
    
    func softDeleteDependentsOf(atom: Atom) {

        let upParticles = atom.upParticles()
        for upParticle in upParticles {
            guard
                let particleSpinIndex = particleIndex.valueFor(key: AnyParticle(spunParticle: upParticle)),
                let atomsForDownSpin = particleSpinIndex.valueFor(key: .down)
                else { continue }
            for atomForDownSpin in atomsForDownSpin {
                guard
                    let observation = atoms.valueFor(key: atomForDownSpin),
                    let observationAtom = observation.atom,
                    atom != observationAtom,
                    (observation.isStore || !observation.isSoft)
                    else { continue }
                
                // Important to delete "leaves" before marking `observationAtom` as "soft deleted"
                softDeleteDependentsOf(atom: observationAtom)
                atoms[observationAtom] = AtomObservation.deleted(observationAtom, isSoft: true)
            }
        }
    }
}

// MARK: - ListenerOf
public extension InMemoryAtomStore {
    final class ListenerOf<Element> {
        private var listeners: [Address: ReplaySubject<Element, Never>] = [:]
        public init() {}
    }
}

extension InMemoryAtomStore.ListenerOf {
    func notifyLister(of address: Address, about element: Element) {
        guard let listenerOfAddress = listener(of: address) else {
            return }
        listenerOfAddress.send(element)
    }
    
    func listener(of address: Address) -> ReplaySubject<Element, Never>? {
        return listeners[address]
    }
    
    func hasListener(of address: Address) -> Bool {
        return listener(of: address) != nil
    }
    
    func addListener(_ subject: ReplaySubject<Element, Never>, of address: Address) {
        guard !hasListener(of: address) else { return }
        listeners[address] = subject
    }
}

// MARK: ReplaySubject + UnlimitedBufferSize
extension ReplaySubject {
    static func unlimitedBufferSize() -> ReplaySubject<Output, Failure> {
        // TODO Combine TODO Entwine change arbitrarily chosen `maxBufferSize`
        return ReplaySubject<Output, Failure>(maxBufferSize: 10_000)
    }
}

