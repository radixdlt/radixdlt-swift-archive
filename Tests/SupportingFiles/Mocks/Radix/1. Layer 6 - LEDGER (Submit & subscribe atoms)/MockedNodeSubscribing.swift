//
//  MockedNodeSubscribing.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-05-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import RxSwift

struct MockedNodeSubscribing: NodeInteractionSubscribing {
    // MARK: - Mocked Response in Observable
    private let observable: Observable<[AtomObservation]>
    
    // MARK: - From Observable
    init(observable: Observable<[AtomObservation]>) {
        self.observable = observable
    }
    
    // MARK: - From Observable via ReplaySubject
    init(replaySubject: ReplaySubject<[AtomObservation]>) {
        self.init(observable: replaySubject.asObservable())
    }
    
    // MARK: - Mocked NodeInteractionSubscribing
    func subscribe(to address: Address) -> Observable<[AtomObservation]> {
        return observable
    }
}
