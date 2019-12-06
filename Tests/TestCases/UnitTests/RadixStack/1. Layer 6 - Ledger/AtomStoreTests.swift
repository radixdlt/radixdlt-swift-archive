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

import XCTest

import Foundation
import Combine
@testable import RadixSDK
import XCTest

private let address: Address = .irrelevant

final class AtomStoreTests: TestCase {
    
    func test_not_nil() {
        let atomStore = InMemoryAtomStore()
        XCTAssertNotNil(atomStore)
    }
    
    func test_that_when_atom_store_is_empty_and_we_store_an___AtomObservation__head___we_get_notified_using_listener_mode___notifyOnAtomUpdateAndSync() {
        doTestStoreSingleHead(notifyListenerMode: .notifyOnAtomUpdateAndSync)
    }
    
    func test_that_when_atom_store_is_empty_and_we_store_an___AtomObservation__head___we_get_notified_using_listener_mode___notifyOnAtomUpdate() {
        doTestStoreSingleHead(notifyListenerMode: .notifyOnAtomUpdate)
    }

    func test_that_when_atom_store_is_empty_and_we_store_an___AtomObservation__head___we_do_NOT_get_notified_using_listener_mode___donʼtNotify() {
        doTest(
            notifyListenerMode: .donʼtNotify,
            expectedAtomObservations: [],
            storing: [AtomObservation.headNow()]
        )
        
    }
    
    func test_that_when_atom_store_is_empty_and_we_store_NONsoft_atom_we_get_notified_using_listener_mode___notifyOnAtomUpdate() {
        doTest_that_when_atom_store_is_empty_and_we_store(atomBeingSoft: false, weGetNotifiedUsingListeningMode: .notifyOnAtomUpdate)
    }
    
    func test_that_when_atom_store_is_empty_and_we_store_soft_atom_we_get_notified_using_listener_mode___notifyOnAtomUpdate() {
        doTest_that_when_atom_store_is_empty_and_we_store(atomBeingSoft: true, weGetNotifiedUsingListeningMode: .notifyOnAtomUpdate)
    }
    
    func test_that_when_atom_store_is_empty_and_we_store_NONsoft_atom_we_get_notified_using_listener_mode___notifyOnAtomUpdateAndSync() {
        doTest_that_when_atom_store_is_empty_and_we_store(atomBeingSoft: false, weGetNotifiedUsingListeningMode: .notifyOnAtomUpdateAndSync)
    }
    
    func test_that_when_atom_store_is_empty_and_we_store_soft_atom_we_get_notified_using_listener_mode___notifyOnAtomUpdateAndSync() {
        doTest_that_when_atom_store_is_empty_and_we_store(atomBeingSoft: true, weGetNotifiedUsingListeningMode: .notifyOnAtomUpdateAndSync)
    }
    
    func test_that_when_atom_store_contains_an_atom_and_we_store_same_atom_it_does_not_get_stored_and_we_do_not_get_any_notification() {
        
        let atom: Atom = .withDestinationAddress(address)
        
        doTest_that_when_atom_store(
            contains: [atom],
            andWeStoreAnAtom: atom,
            atomBeingStoredIs: .soft,
            weGetNotifiedUsingListeningMode: .notifyOnAtomUpdateAndSync,
            expectedAtomObservations: []
        )
    }
    
    func test_when_subscribed_before_an_atom_is_stored_on_a_different_address__then_the_atom_should_not_be_observed() {
        let store = InMemoryAtomStore()
        
        var outputtedObservations = [AtomObservation]()
        let expectation = XCTestExpectation(description: self.debugDescription)

        let address: Address = .irrelevant(index: 1)
        let cancellable = store.atomObservations(of: address)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { outputtedObservations.append($0) }
            )
        let differentAddress: Address = .irrelevant(index: 2)
        store.store(atomObservation: AtomObservation.headNow(), address: differentAddress, notifyListenerMode: .notifyOnAtomUpdate)
        expectation.fulfill()
        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(outputtedObservations.isEmpty)
        XCTAssertNotNil(cancellable)
    }
    
    func test_when_subscribed_before_an_atom_is_stored_on_same_address__then_the_atom_should_be_observed() {
        let store = InMemoryAtomStore()
        
        var outputtedObservations = [AtomObservation]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let address: Address = .irrelevant(index: 1)
        let cancellable = store.atomObservations(of: address)
            .first()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { outputtedObservations.append($0) }
        )
        store.store(atomObservation: AtomObservation.headNow(), address: address, notifyListenerMode: .notifyOnAtomUpdate)
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(outputtedObservations.count, 1)
        XCTAssertNotNil(cancellable)
    }
    
  
    // MARK: Replay
    func test_when_subscribed_after_an_atom_is_stored_on_a_DIFFERENT_address__then_the_atom_should_NOT_be_observed_replay_of_1() {
        let store = InMemoryAtomStore()
        
        var outputtedObservations = [AtomObservation]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let address: Address = .irrelevant(index: 1)
        let differentAddress: Address = .irrelevant(index: 2)
        store.store(atomObservation: AtomObservation.headNow(), address: differentAddress, notifyListenerMode: .notifyOnAtomUpdate)
        let cancellable = store.atomObservations(of: address)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { outputtedObservations.append($0) }
        )
        expectation.fulfill()
        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(outputtedObservations.isEmpty)
        XCTAssertNotNil(cancellable)
    }
    
    func test_when_subscribed_after_genesis_atoms_are_stored_on_same_address__then_the_atom_should_be_observed_replay_of_many() {
        let address: Address = .irrelevant
        let atomCount = 10
        let genesisAtoms = Array<Int>(0..<atomCount).map { Atom.withDestinationAddress(address, date: Date().advanced(by: TimeInterval($0))) }
        XCTAssertEqual(genesisAtoms.count, atomCount)
        let atomStore = InMemoryAtomStore(genesisAtoms: genesisAtoms)
        let publisher = atomStore.atomObservations(of: address)
        
        var outputtedObservations = [AtomObservation]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let cancellable = publisher
            .prefix(atomCount)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { outputtedObservations.append($0) }
        )
        
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(outputtedObservations.count, atomCount)
        XCTAssertNotNil(cancellable)
    }
    
    
    func test_when_subscribed_after_an_atom_is_stored_on_same_address__then_the_atom_should_be_observed_replay_of_many() {
        let address: Address = .irrelevant
      
        let atomStore = InMemoryAtomStore()
        let publisher = atomStore.atomObservations(of: address)
        
        var outputtedObservations = [AtomObservation]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let atomCount = 10
        let atoms = Array<Int>(0..<atomCount).map { Atom.withDestinationAddress(address, date: Date().advanced(by: TimeInterval($0))) }
        XCTAssertEqual(atoms.count, atomCount)
        for atom in atoms {
            atomStore.store(atomObservation: .stored(atom), address: address, notifyListenerMode: .notifyOnAtomUpdateAndSync)
        }
        
        let cancellable = publisher
            .prefix(atomCount)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { outputtedObservations.append($0) }
        )
        
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(outputtedObservations.count, atomCount)
        XCTAssertNotNil(cancellable)
    }
    
    func test_when_receiving_atom_deletes_for_atoms_which_have_not_been_seen__store_should_not_propagate_delete_event() {
        let atomStore = InMemoryAtomStore()
        
        let address: Address = .irrelevant
        
        let atom: Atom = .withDestinationAddress(address)
        let observationDelete = AtomObservation.deleted(atom)
        XCTAssertFalse(observationDelete.isSoft)

        let observationStore = AtomObservation.stored(atom)
        XCTAssertFalse(observationStore.isSoft)
        
        atomStore.store(atomObservation: observationDelete, address: address, notifyListenerMode: .notifyOnAtomUpdateAndSync)
        atomStore.store(atomObservation: observationStore, address: address, notifyListenerMode: .notifyOnAtomUpdateAndSync)
        
        var outputtedObservations = [AtomObservation]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let cancellable = atomStore.atomObservations(of: address)
            .first()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { outputtedObservations.append($0) }
        )
        
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(outputtedObservations.count, 1)
        let observationFetched: AtomObservation! = XCTAssertType(of: outputtedObservations[0])
        XCTAssertEqual(observationFetched, observationStore)
        XCTAssertNotNil(cancellable)
    }
    
    func test_when_receiving_atom_store_then_delete_then_store_for_an_atom_then_subscribe__store_should_propagate_one_store_event() {
        let atomStore = InMemoryAtomStore()
        
        let address: Address = .irrelevant
        
        let atom: Atom = .withDestinationAddress(address)
        let observationDelete = AtomObservation.deleted(atom)
        XCTAssertFalse(observationDelete.isSoft)
        
        let observationStore = AtomObservation.stored(atom)
        XCTAssertFalse(observationStore.isSoft)
        
        atomStore.store(atomObservation: observationStore, address: address, notifyListenerMode: .notifyOnAtomUpdateAndSync)
        atomStore.store(atomObservation: observationDelete, address: address, notifyListenerMode: .notifyOnAtomUpdateAndSync)
        atomStore.store(atomObservation: observationStore, address: address, notifyListenerMode: .notifyOnAtomUpdateAndSync)
        
        var outputtedObservations = [AtomObservation]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let cancellable = atomStore.atomObservations(of: address)
            .first()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { outputtedObservations.append($0) }
        )
        
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(outputtedObservations.count, 1)
        let observationFetched: AtomObservation! = XCTAssertType(of: outputtedObservations[0])
        XCTAssertEqual(observationFetched, observationStore)
        XCTAssertNotNil(cancellable)
    }
    
    func test_when_getting_up_particles_with_an_empty_store__store_should_return_an_empty_stream() {
        let atomStore = InMemoryAtomStore()
        let upParticles = atomStore.upParticles(at: .irrelevant)
        XCTAssertTrue(upParticles.isEmpty)
    }
    
    func test_when_getting_up_particles_from_store_with_an_atom_with_no_particles__store_should_return_an_empty_stream() {
        let atomStore = InMemoryAtomStore()
        let atom = Atom(metaData: .timeNow)
        let address = Address.irrelevant
        atomStore.store(atomObservation: .stored(atom), address: address, notifyListenerMode: .notifyOnAtomUpdateAndSync)
        let upParticles = atomStore.upParticles(at: address)
        XCTAssertTrue(upParticles.isEmpty)
    }
    
    func test_when_getting_up_particles_from_store_with_an_atom_with_one_up_particle__store_should_return_that_particle() throws {
        let atomStore = InMemoryAtomStore()
        let address = Address.irrelevant
        let rri: ResourceIdentifier = "/\(address)/FOOBAR"
        let rriParticle =  ResourceIdentifierParticle(resourceIdentifier: rri)
        let spunUpRRIParticle = rriParticle.withSpin(.up)
        let particleGroup = try  spunUpRRIParticle.wrapInGroup()
        let atom = Atom(metaData: .timeNow, particleGroups: [particleGroup])
        atomStore.store(atomObservation: .stored(atom), address: address, notifyListenerMode: .notifyOnAtomUpdateAndSync)
        let upParticles = atomStore.upParticles(at: address)
        XCTAssertEqual(upParticles.count, 1)
        guard let fetchedRRIParticle = upParticles[0].someParticle as? ResourceIdentifierParticle else {
            return XCTFail("Wrong type")
        }
        XCTAssertEqual(rriParticle, fetchedRRIParticle)
    }
    
    func test_when_getting_up_particles_from_store_with_an_atom_with_one_down_particle__store_should_return_an_empty_stream() throws {
        let atomStore = InMemoryAtomStore()
        let address = Address.irrelevant
        let rri: ResourceIdentifier = "/\(address)/FOOBAR"
        let rriParticle =  ResourceIdentifierParticle(resourceIdentifier: rri)
        let particleGroup = try rriParticle.withSpin(.down).wrapInGroup()
        let atom = Atom(metaData: .timeNow, particleGroups: [particleGroup])
        atomStore.store(atomObservation: .stored(atom), address: address, notifyListenerMode: .notifyOnAtomUpdateAndSync)
        let upParticles = atomStore.upParticles(at: address)
        XCTAssertTrue(upParticles.isEmpty)
    }
    
    func test_when_getting_up_particles_from_store_with_an_atom_with_one_up_particle_then_deleted__store_should_return_an_empty_stream() throws {
        let atomStore = InMemoryAtomStore()
        let address = Address.irrelevant
        let rri: ResourceIdentifier = "/\(address)/FOOBAR"
        let rriParticle =  ResourceIdentifierParticle(resourceIdentifier: rri)
        let spunUpRRIParticle = rriParticle.withSpin(.up)
        let particleGroup = try  spunUpRRIParticle.wrapInGroup()
        let atom = Atom(metaData: .timeNow, particleGroups: [particleGroup])
        atomStore.store(atomObservation: .stored(atom), address: address, notifyListenerMode: .notifyOnAtomUpdateAndSync)
        atomStore.store(atomObservation: .deleted(atom), address: address, notifyListenerMode: .notifyOnAtomUpdateAndSync)
        let upParticles = atomStore.upParticles(at: address)
        XCTAssertTrue(upParticles.isEmpty)
    }
    
    func test_when_getting_up_particles_from_store_with_dependent_deletes__store_should_return_an_empty_stream() throws {
        let atomStore = InMemoryAtomStore()
        let someAddress = Address.irrelevant
        let particle0 =  ResourceIdentifierParticle(resourceIdentifier: "/\(someAddress)/FOO")

        let atom0 = Atom(
            metaData: .timeNow,
            particleGroups: [try ParticleGroup(spunParticles: [particle0.withSpin(.up)], metaData: .timeNow)]
        )
        
        XCTAssertEqual(atomStore.upParticles(at: someAddress).count, 0)
        atomStore.store(atomObservation: .stored(atom0), address: someAddress, notifyListenerMode: .notifyOnAtomUpdateAndSync)
        XCTAssertEqual(atomStore.upParticles(at: someAddress).count, 1)
        
        let particle1 =  ResourceIdentifierParticle(resourceIdentifier: "/\(someAddress)/BAR")
        let particle2 =  ResourceIdentifierParticle(resourceIdentifier: "/\(someAddress)/BUZ")
        
        let atom1 = Atom(
            metaData: .timeNow,
            particleGroups: [
                try ParticleGroup(
                    spunParticles: [
                        particle0.withSpin(.down),
                        particle1.withSpin(.up),
                        particle2.withSpin(.up)
                    ],
                    metaData: .timeNow)
            ]
        )
        
        atomStore.store(atomObservation: .stored(atom1), address: someAddress, notifyListenerMode: .notifyOnAtomUpdateAndSync)
        XCTAssertEqual(atomStore.upParticles(at: someAddress).count, 2)
        atomStore.store(atomObservation: .deleted(atom0), address: someAddress, notifyListenerMode: .notifyOnAtomUpdateAndSync)

        XCTAssertEqual(atomStore.upParticles(at: someAddress).count, 0)
    }
    
    func test_when_getting_up_particles_from_store_where_collision_occurred_on_soft_state__store_should_return_winner_particle() throws {
        let atomStore = InMemoryAtomStore()
        let someAddress = Address.irrelevant
        
        
        let particle0 =  ResourceIdentifierParticle(resourceIdentifier: "/\(someAddress)/FOO")
        let particle1 =  ResourceIdentifierParticle(resourceIdentifier: "/\(someAddress)/BAR")
        
        let timeNow = Date()
        
        let atom0 = Atom(
            metaData: .timestamp(timeNow.advanced(by: 0)),
            particleGroups: [
                try ParticleGroup(
                    spunParticles: [
                        particle0.withSpin(.down),
                        particle1.withSpin(.up) // <- Particle1️⃣
                    ],
                    metaData: .timeNow)
            ]
        )

        atomStore.store(atomObservation: AtomObservation.stored(atom0, isSoft: true), address: someAddress, notifyListenerMode: .notifyOnAtomUpdateAndSync)

        let particle2 =  ResourceIdentifierParticle(resourceIdentifier: "/\(someAddress)/BUZ")
       
        let atom1 = Atom(
            metaData: .timestamp(timeNow.advanced(by: 1)),
            particleGroups: [
                try ParticleGroup(
                    spunParticles: [
                        particle0.withSpin(.down),
                        particle2.withSpin(.up) // <- Particle2️⃣
                    ],
                    metaData: .timeNow)
            ]
        )
        
        atomStore.store(atomObservation: .stored(atom1), address: someAddress, notifyListenerMode: .notifyOnAtomUpdateAndSync)
        
        let upParticles = atomStore.upParticles(at: someAddress)
        XCTAssertEqual(upParticles.count, 1)
        guard let fetchedRRIParticle = upParticles[0].someParticle as? ResourceIdentifierParticle else {
            return XCTFail("Wrong type")
        }
        XCTAssertEqual(fetchedRRIParticle, particle2) // <- Particle2️⃣
    }

    func test___onSync___when_subscribed_before_a_head_is_stored_on_same_address_using_listener_mode___notifyOnSync___then_a_date_should_be_observed() {
        let atomStore = InMemoryAtomStore()
        
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        var outputtedValues = [Date]()
        
        let expectedNumberOfOutputtedValues = 1
        
        let cancellable = atomStore.onSync(address: address)
            .prefix(expectedNumberOfOutputtedValues)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { outputtedValues.append($0) }
            )
        
        let date1 = Date(timeIntervalSinceNow: -10_000)
        let milliseconds10Ago: TimeInterval = -0.01
        XCTAssertGreaterThanOrEqual(abs(date1.timeIntervalSinceNow), abs(milliseconds10Ago))
        
        atomStore.store(atomObservation: .head(receivedAt: date1), address: address, notifyListenerMode: .notifyOnSync)
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(outputtedValues.count, expectedNumberOfOutputtedValues)
        XCTAssertNotEqual(outputtedValues[0], date1, "The date of the sync should not be the same as the date of the AtomObservation")
        XCTAssertGreaterThanOrEqual(outputtedValues[0].timeIntervalSinceNow, milliseconds10Ago) // max 10 ms ago
        
        XCTAssertNotNil(cancellable)
    }
    
    func test___onSync___when_subscribed_after_a_head_is_stored_on_same_address_using_listener_mode___notifyOnSync___then_a_date_should_be_observed() {
        
        let atomStore = InMemoryAtomStore()
        
        let expectation = XCTestExpectation(description: self.debugDescription)
        var outputtedValues = [Date]()
        let expectedNumberOfOutputtedValues = 1
        
        let date1 = Date(timeIntervalSinceNow: -10_000)
        atomStore.store(atomObservation: .head(receivedAt: date1), address: address, notifyListenerMode: .notifyOnSync)
        
        let cancellable = atomStore.onSync(address: address)
            .prefix(expectedNumberOfOutputtedValues)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { outputtedValues.append($0) }
        )
        
        let milliseconds10Ago: TimeInterval = -0.01
        XCTAssertGreaterThanOrEqual(abs(date1.timeIntervalSinceNow), abs(milliseconds10Ago))
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(outputtedValues.count, expectedNumberOfOutputtedValues)
        XCTAssertNotEqual(outputtedValues[0], date1, "The date of the sync should not be the same as the date of the AtomObservation")
        XCTAssertGreaterThanOrEqual(outputtedValues[0].timeIntervalSinceNow, milliseconds10Ago) // max 10 ms ago
        
        XCTAssertNotNil(cancellable)
    }
    
    func test___onSync___when_subscribed_before_a_head_is_stored_on_same_address_using_listener_mode___donʼtNotify___then_a_date_should_be_observed() {
        
        let atomStore = InMemoryAtomStore()
        
        let expectation = XCTestExpectation(description: self.debugDescription)
        var outputtedValues = [Date]()
        
        let cancellable = atomStore.onSync(address: address)
            .first()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { outputtedValues.append($0) }
            )
        
        
        atomStore.store(atomObservation: .headNow(), address: address, notifyListenerMode: .donʼtNotify)
        expectation.fulfill()
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(outputtedValues.count, 0)
        XCTAssertNotNil(cancellable)
    }
   
    func test___onSync___when_subscribed_before_a_head_is_stored_on_different_address_we_dont_get_notified() {
        
        let atomStore = InMemoryAtomStore()
        let alice: Address = .irrelevant(index: 1)
        let bob: Address = .irrelevant(index: 2)
        
        let expectation = XCTestExpectation(description: self.debugDescription)
        var outputtedValues = [Date]()
        
        let cancellable = atomStore.onSync(address: alice)
            .first()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { outputtedValues.append($0) }
            )
        
        
        atomStore.store(atomObservation: .headNow(), address: bob, notifyListenerMode: .notifyOnSync)
        expectation.fulfill()
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(outputtedValues.count, 0)
        XCTAssertNotNil(cancellable)
    }
    
    func test___onSync___when_subscribed_after_a_head_is_stored_on_different_address_we_dont_get_notified() {
        
        let atomStore = InMemoryAtomStore()
        let alice: Address = .irrelevant(index: 1)
        let bob: Address = .irrelevant(index: 2)
        
        let expectation = XCTestExpectation(description: self.debugDescription)
        var outputtedValues = [Date]()
        
        atomStore.store(atomObservation: .headNow(), address: bob, notifyListenerMode: .notifyOnSync)

        let cancellable = atomStore.onSync(address: alice)
            .first()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { outputtedValues.append($0) }
        )
        
        expectation.fulfill()
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(outputtedValues.count, 0)
        XCTAssertNotNil(cancellable)
    }
}

extension Array where Element == Atom {
    static var noAtoms: Self { [] }
}

enum SoftOrHardAtomObservation: Int, Equatable {
    case soft
    case nonSoft
}
extension SoftOrHardAtomObservation {
    var isSoft: Bool { self == .soft }
    init(isSoft: Bool) {
        if isSoft {
            self = .soft
        } else {
            self = .nonSoft
        }
    }
}

private extension AtomStoreTests {
    
    
    func doTest_that_when_atom_store_is_empty_and_we_store(atomBeingSoft isSoft: Bool, weGetNotifiedUsingListeningMode mode: AtomNotificationMode) {
        doTest_that_when_atom_store(contains: .noAtoms, atomBeingStoredIs: SoftOrHardAtomObservation(isSoft: isSoft), weGetNotifiedUsingListeningMode: mode)
    }
    
    func doTest_that_when_atom_store(
        contains genesisAtoms: [Atom],
        andWeStoreAnAtom overridingAtom: Atom? = nil,
        atomBeingStoredIs softOrNot: SoftOrHardAtomObservation,
        weGetNotifiedUsingListeningMode mode: AtomNotificationMode,
        expectedAtomObservations overridingExpectedAtomObservations: [AtomObservation]? = nil
    ) {
        XCTAssertNotEqual(mode, .donʼtNotify)
        
        let atom: Atom = overridingAtom ?? .withDestinationAddress(address)
        
        let atomUpdateStored = AtomObservation.store(atom: atom, soft: softOrNot.isSoft, receivedAt: .init())
        
        doTest(
            notifyListenerMode: mode,
            expectedAtomObservations: overridingExpectedAtomObservations ?? [atomUpdateStored],
            genesisAtoms: genesisAtoms,
            storing: [atomUpdateStored]
        )
    }
    
    func doTest(
        notifyListenerMode: AtomNotificationMode,
        expectedAtomObservations: [AtomObservation],
        genesisAtoms: [Atom] = [],
        line: UInt = #line,
        
        storing: @autoclosure () -> [AtomObservation]
    ) {
        let atomStore = InMemoryAtomStore(genesisAtoms: genesisAtoms)
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let atomUpdateListener = atomStore.atomObservations(of: address)
        
        var outputtedAtomObservations = [AtomObservation]()
        let expectedNumberOfOutputtedAtomObservations = expectedAtomObservations.count
        let cancellable = atomUpdateListener
            .prefix(expectedNumberOfOutputtedAtomObservations)
            .sink(
                receiveCompletion: { _ in expectation.fulfill()  },
                receiveValue: { outputtedAtomObservations.append($0) }
        )
        
        for atomObservation in storing() {
            atomStore.store(
                atomObservation: atomObservation,
                address: address,
                notifyListenerMode: notifyListenerMode
            )
        }
        
        if expectedNumberOfOutputtedAtomObservations == 0 {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(outputtedAtomObservations.count, expectedNumberOfOutputtedAtomObservations, line: line)
        XCTAssertEqual(outputtedAtomObservations, expectedAtomObservations, line: line)
        XCTAssertNotNil(cancellable, line: line)
    }
    
    func doTestStoreExpected(
        notifyListenerMode: AtomNotificationMode,
        expectedAtomObservations: [AtomObservation],
        line: UInt = #line
    ) {
        doTest(
            notifyListenerMode: notifyListenerMode,
            expectedAtomObservations: expectedAtomObservations,
            line: line,
            storing: expectedAtomObservations
        )
    }
    
    func doTestStoreSingleHead(
        notifyListenerMode: AtomNotificationMode,
        line: UInt = #line
    ) {
        
        doTestStoreExpected(
            notifyListenerMode: notifyListenerMode,
            expectedAtomObservations: [AtomObservation.headNow()],
            line: line
        )
    }
}
