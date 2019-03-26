//
//  RadixJsonRpcClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol RadixJsonRpcClient {
    func getInfo() -> Single<NodeRunnerData>
    func getLivePeers() -> Single<[NodeRunnerData]>
    func getAtom(by hashId: EUID) -> Maybe<Atom>
    func getAtoms(query: AtomQuery) -> Observable<AtomObservation>
    func submitAtom(_ atom: Atom) -> Observable<NodeAtomSubmissionUpdate>
}
