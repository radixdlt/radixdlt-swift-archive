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
    
    // TODO move out to separate test
    func test_atoms_equal() {
        let address: Address = .irrelevant
        let date = Date()
        let atom1 = Atom.withDestinationAddress(address, date: date)
        let atom2 = Atom.withDestinationAddress(address, date: date)
        XCTAssertEqual(atom1, atom2)
    }
    
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
