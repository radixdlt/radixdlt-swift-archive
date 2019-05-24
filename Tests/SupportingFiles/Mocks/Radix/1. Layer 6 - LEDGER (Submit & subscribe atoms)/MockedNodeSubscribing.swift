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
    private let observable: Observable<[AtomUpdate]>
    
    // MARK: - From Observable
    init(observable: Observable<[AtomUpdate]>) {
        self.observable = observable
    }
    
    // MARK: - From Observable via ReplaySubject
    init(replaySubject: ReplaySubject<[AtomUpdate]>) {
        self.init(observable: replaySubject.asObservable())
    }
    
    // MARK: - Mocked NodeInteractionSubscribing
    func subscribe(to address: Address) -> Observable<[AtomUpdate]> {
        return observable
    }
}
