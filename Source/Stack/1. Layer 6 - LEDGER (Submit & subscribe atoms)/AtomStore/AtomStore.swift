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

public protocol AtomStore {
    
    /// Interface for propagating when the current store
    /// is synced with some node on a given address.
    ///
    /// - Parameter address: The address to check for sync
    /// - Returns: a never ending observable which emits timestamp for when this local `AtomStore` is
    /// synced with some origin
    func onSync(address: Address) -> Observable<Date>
    
    /// Retrieves a never ending observable of atom observations (`stored` and `deleted`)
    /// which are then processed by the local store
    func atomObservations(of address: Address) -> Observable<AtomObservation>
    
    func upParticles(at address: Address, stagedUuid: UUID?) -> [AnyUpParticle]
    
    /// Stores an Atom (wrapped in AtomObservation) under a given destination (Address) and not
    func store(atomObservation: AtomObservation, address: Address, notifyListenerMode: AtomNotificationMode)
    
    func stageParticleGroup(_ particleGroup: ParticleGroup, uuid: UUID)

    @discardableResult
    func clearStagedParticleGroups(for uuid: UUID) -> ParticleGroups?
}

public final class InMemoryAtomStore: AtomStore {
    public final class ListenerOf<Element> {
        private var listeners: [Address: ReplaySubject<Element>] = [:]
        public init() {}
    }
    
    private var stagedAtoms         = [UUID: Atom]()
    private var atoms               = [Atom: AtomObservation]()
    
    private var stagedParticleIndex = [UUID: [AnyParticle: Spin]]()
    private var particleIndex       = [AnyParticle: [Spin: Set<Atom>]]()
    
    private var synced              = [Address: Bool]()

    private var atomUpdateListeners: ListenerOf<AtomObservation>
    private var syncListeners: ListenerOf<Date>
    
    public init(
        genesisAtoms: [Atom] = [],
        atomUpdateListeners: ListenerOf<AtomObservation> = .init(),
        syncListeners: ListenerOf<Date> = .init()
    ) {
        self.atomUpdateListeners = atomUpdateListeners
        self.syncListeners = syncListeners
        
        // Store genesis atoms
        genesisAtoms.forEach { atom in
            atom.addresses().forEach {
                let atomObservation = AtomObservation.stored(atom)
                self.store(
                    atomObservation: atomObservation,
                    address: $0,
                    // TODO change `notifyListenerMode` to `.dontNotify`?
                    notifyListenerMode: .notifyOnAtomUpdateAndSync
                )
            }
            atom.addresses().forEach {
                self.store(atomObservation: AtomObservation.head(), address: $0, notifyListenerMode: .notifyOnAtomUpdateAndSync)
            }
        }
    }
}

public extension InMemoryAtomStore {
    
    func onSync(address: Address) -> Observable<Date> {
        if let existingListenerAtAddress = syncListeners.listener(of: address) {
            return existingListenerAtAddress.asObservable()
        } else {
            let newListener = ReplaySubject<Date>.createUnbounded()
            syncListeners.addListener(newListener, of: address)
            defer {
                if synced.valueForKey(key: address, ifAbsent: { false }) {
                    newListener.onNext(Date())
                }
            }
            return newListener.asObservable()
        }
    }
    
    func atomObservations(of address: Address) -> Observable<AtomObservation> {
        
        if let existingListenerAtAddress = atomUpdateListeners.listener(of: address) {
            return existingListenerAtAddress.asObservable()
        } else {
            let newListener = ReplaySubject<AtomObservation>.createUnbounded()
            atomUpdateListeners.addListener(newListener, of: address)
            // Replay history
            atoms.filter {
                $0.value.isStore && $0.key.addresses().contains(address)
            }.compactMap {
                $0.value
            }.forEach { newListener.onNext($0) }
            return newListener.asObservable()
        }

    }
    
    func upParticles(at address: Address, stagedUuid: UUID?) -> [AnyUpParticle] {
        var upParticles = particleIndex.filter {
            guard $0.key.getParticle().shardables()?.contains(address) == true else { return false }
            var spinParticleIndex = $0.value
            let hasDown = spinParticleIndex.valueForKey(key: .down, ifAbsent: { Set() }).contains(where: { atoms[$0]?.isStore == true })
            if hasDown { return false }
            if let stagedUuid = stagedUuid, stagedParticleIndex.valueForKey(key: stagedUuid, ifAbsent: { [AnyParticle: Spin]() }).valueFor(key: $0.key) == Spin.down {
                return false
            }
            let uppingAtoms = spinParticleIndex.valueForKey(key: .up, ifAbsent: { Set() })
            return uppingAtoms.contains(where: { atom in
                guard let atomObservation = self.atoms.valueFor(key: atom) else { return false }
                return atomObservation.isStore
            })
        }
        .map { $0.key }
        
        if let stagedUuid = stagedUuid {
            stagedParticleIndex
                .valueForKey(key: stagedUuid, ifAbsent: { [AnyParticle: Spin]() })
                .filter { $0.value == Spin.up }
                .map { $0.key }
                .forEach { upParticles.append($0) }
        }
        
        return upParticles
            .asSet.asArray // remove any duplicates
            .map { $0.getParticle() }
            .map { AnyUpParticle(particle: $0) }
    }
    
    func stageParticleGroup(_ particleGroup: ParticleGroup, uuid: UUID) {
        let stagedAtom: Atom
        if let atomInStaged = stagedAtoms.valueFor(key: uuid) {
            let groups: ParticleGroups = atomInStaged.particleGroups + particleGroup
            stagedAtom = Atom(particleGroups: groups)
        } else {
            stagedAtom = Atom(particleGroup)
        }
        stagedAtoms[uuid] = stagedAtom
        
        for spunParticle in particleGroup.spunParticles {
            stagedParticleIndex[uuid] = stagedParticleIndex
                .valueForKey(key: uuid, ifAbsent: { [AnyParticle: Spin]() })
                .inserting(value: spunParticle.spin, forKey: AnyParticle(someParticle: spunParticle.particle))
        }
    }
    
    @discardableResult
    func clearStagedParticleGroups(for uuid: UUID) -> ParticleGroups? {
        defer { stagedParticleIndex.removeValue(forKey: uuid) }
        guard let atom = stagedAtoms.removeValue(forKey: uuid) else { return nil }
        return atom.particleGroups
    }
    
    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func store(atomObservation: AtomObservation, address: Address, notifyListenerMode: AtomNotificationMode) {
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
            spunParticlesInAtomLoop: for spunParticle in atom.spunParticles() {
                guard
                    let spinParticleIndex = particleIndex.valueFor(key: AnyParticle(someParticle: spunParticle.particle)),
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
            atom.spunParticles().forEach { spunParticle in
                let key = AnyParticle(someParticle: spunParticle.particle)
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
            atom.addresses().forEach {
                atomUpdateListeners.notifyLister(of: $0, about: atomObservation)
            }
        }
        
    }
}

private extension InMemoryAtomStore {
    func softDeleteDependentsOf(atom: Atom) {
        let upParticles = atom.spunParticles().filter(spin: .up)
        for upParticle in upParticles {
            guard
                let particleSpinIndex = particleIndex.valueFor(key: AnyParticle(someParticle: upParticle.particle)),
                let atomsForDownSpin = particleSpinIndex.valueFor(key: .down)
                else { continue }
            for atomForDownSpin in atomsForDownSpin {
                guard
                    let observation = atoms.valueFor(key: atomForDownSpin),
                    let observationAtom = observation.atom,
                    atomForDownSpin != observationAtom,
                    (observation.isStore || !observation.isSoft)
                else { continue }
              
                // Important to delete "leaves" before marking `observationAtom` as "soft deleted"
                softDeleteDependentsOf(atom: observationAtom)
                atoms[observationAtom] = AtomObservation.deleted(observationAtom, isSoft: true)
            }
        }
    }
}

extension InMemoryAtomStore.ListenerOf {
    func notifyLister(of address: Address, about element: Element) {
        guard let listenerOfAddress = listener(of: address) else {
            return }
        listenerOfAddress.onNext(element)
    }
    
    func listener(of address: Address) -> ReplaySubject<Element>? {
        return listeners[address]
    }
    
    func hasListener(of address: Address) -> Bool {
        return listener(of: address) != nil
    }
    
    func addListener(_ subject: ReplaySubject<Element>, of address: Address) {
        guard !hasListener(of: address) else { return }
        listeners[address] = subject
    }
}
