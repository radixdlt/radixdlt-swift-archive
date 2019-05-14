//
//  NodeInteracting.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol NodeInteractingSubscribe {
    var nodeSubscriber: NodeInteractionSubscribing { get }
}

public protocol NodeInteractingUnubscribe {
   var nodeUnsubscriber: NodeInteractionUnsubscribing { get }
}

public protocol NodeInteractingSubmit {
   var nodeSubmitter: NodeInteractionSubmitting { get }
}

public typealias NodeInteracting = NodeInteractingSubscribe & NodeInteractingUnubscribe & NodeInteractingSubmit
