//
//  InMemoryStore.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public struct AnyParticle: Hashable {
    
    private let _getParticle: () -> ParticleConvertible
    private let _hashInto: (inout Swift.Hasher) -> Void
    
//    public init<Concrete>(_ concrete: Concrete) where Concrete: ParticleConvertible {
//        self._getParticle = { concrete }
//        self._hashInto = { $0.combine(concrete.hashId) }
//    }
    public init(someParticle: ParticleConvertible) {
        self._getParticle = { someParticle }
        self._hashInto = { $0.combine(someParticle.hashId) }
    }
}
public extension AnyParticle {
    func getParticle() -> ParticleConvertible {
        return self._getParticle()
    }
}
public extension AnyParticle {
    static func == (lhs: AnyParticle, rhs: AnyParticle) -> Bool {
        return lhs.getParticle().hashId == rhs.getParticle().hashId
    }
    
    func hash(into hasher: inout Hasher) {
        self._hashInto(&hasher)
    }
}

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
    
    func upParticles(at address: Address, stagedUuid: UUID?) -> [ParticleConvertible]
    
    /// Stores an Atom (wrapped in AtomObservation) under a given destination (Address) and not
    func store(atomObservation: AtomObservation, address: Address, notifyListeners: AtomNotificationMode)
    
    func stateParticleGroup(_ particleGroup: ParticleGroup, uuid: UUID)

    func clearStagedParticleGroups(for uuid: UUID) -> ParticleGroups
}

public final class InMemoryAtomStore: AtomStore {
    public final class ListenerOf<Element> {
        private var listeners: [Address: [PublishSubject<Element>]] = [:]
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
        genesisAtoms.forEach { atom in
            atom.addresses().forEach {
                let atomObservation = AtomObservation.stored(atom)
                self.store(
                    atomObservation: atomObservation,
                    address: $0,
                    notifyListeners: .dontNotify
                )
            }
        }
    }
}

public extension InMemoryAtomStore {
    
    func onSync(address: Address) -> Observable<Date> {
        return Observable.create { [unowned self] observer in
            if self.synced.valueForKey(key: address, ifAbsent: { false }) {
                observer.onNext(Date())
            }

            var disposables = [Disposable]()
            
            let syncList: [PublishSubject<Date>]
            
            if !self.syncListeners.hasAnyListener(for: address) {
                let subject = PublishSubject<Date>()
                self.syncListeners.addLister(subject: subject, forAddress: address)
                syncList = [subject]
            } else {
                // swiftlint:disable:next force_unwrap
                syncList = self.syncListeners.listers(of: address)!
                
            }
            syncList.forEach {
                disposables.append($0.subscribe(observer))
            }
            return Disposables.create(disposables)
        }
    }
    
    func atomObservations(of address: Address) -> Observable<AtomObservation> {
        implementMe()
    }
    
    func upParticles(at address: Address, stagedUuid: UUID?) -> [ParticleConvertible] {
        var upParticles = particleIndex.filter {
            guard $0.key.getParticle().shardables()?.contains(address) == true else { return false }
            var spinParticleIndex = $0.value
            let hasDown = spinParticleIndex.valueForKey(key: .down, ifAbsent: { Set() }).contains(where: { atoms[$0]?.isStore == true })
            if hasDown { return false }
            if let stagedUuid = stagedUuid, stagedParticleIndex.valueForKey(key: stagedUuid, ifAbsent: { [AnyParticle: Spin]() }).valueFor(key: $0.key) == Spin.down {
                return false
            }
            let uppingAtoms = spinParticleIndex.valueForKey(key: .up, ifAbsent: { Set() })
            return uppingAtoms.contains(where: { atoms[$0]?.isStore == true })
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
    }
    
    func stateParticleGroup(_ particleGroup: ParticleGroup, uuid: UUID) {
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
    
    func clearStagedParticleGroups(for uuid: UUID) -> ParticleGroups {
        guard let atom = stagedAtoms.removeValue(forKey: uuid) else { incorrectImplementation("Found no staged atom for uuid: '\(uuid)'") }
        stagedParticleIndex.removeValue(forKey: uuid)
        return atom.particleGroups
    }
    
    // swiftlint:disable:next function_body_length
    func store(atomObservation: AtomObservation, address: Address, notifyListeners: AtomNotificationMode) {
        let areAtomsInSync = atomObservation.isHead
        defer {
            synced[address] = areAtomsInSync
            if areAtomsInSync, notifyListeners.shouldNotifyOnSync {
                syncListeners.notifyAll(about: Date(), address: address)
            }
        }
        
        guard let atom = atomObservation.atom else {
            if notifyListeners.shouldNotifyOnAtomUpdate {
                atomUpdateListeners.notifyAll(about: atomObservation, address: address)
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
        if let currentAtomObservation = atoms[atom] {
            includeAtom = (!atomObservation.isSoft || currentAtomObservation.isSoft) && !atomObservation.isSameType(as: currentAtomObservation)
        } else {
            includeAtom = atomObservation.isStore
            atom.spunParticles().forEach { spunParticle in
                let key = AnyParticle(someParticle: spunParticle.particle)
                let spinParticleIndex = particleIndex.valueForKey(key: key) { [Spin: Set<Atom>]() }
                particleIndex[key] = spinParticleIndex.merging([spunParticle.spin: [atom].asSet], uniquingKeysWith: { $0.union($1) })
            }
        }
        
        if includeAtom, notifyListeners.shouldNotifyOnAtomUpdate {
            atom.addresses().forEach {
                atomUpdateListeners.notifyAll(about: atomObservation, address: $0)
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
    func notifyAll(about element: Element, address: Address) {
        guard let listenersOfAddress = listers(of: address) else { return }
        listenersOfAddress.forEach { $0.onNext(element) }
    }
    
    func listers(of address: Address) -> [PublishSubject<Element>]? {
        return listeners[address]
    }
    
    func hasAnyListener(for address: Address) -> Bool {
        let subjetsOrEmpty = listeners.valueForKey(key: address, ifAbsent: { [PublishSubject<Element>]() })
        return !subjetsOrEmpty.isEmpty
    }
    
    func addLister(subject: PublishSubject<Element>, forAddress address: Address) {
        var subjects = listeners.valueForKey(key: address, ifAbsent: { [PublishSubject<Element>]() })
        subjects.append(subject)
        listeners[address] = subjects
    }
}
