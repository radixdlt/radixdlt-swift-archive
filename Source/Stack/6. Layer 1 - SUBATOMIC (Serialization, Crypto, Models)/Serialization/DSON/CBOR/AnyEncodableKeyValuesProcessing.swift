//
//  AnyEncodableKeyValuesProcessing.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol AnyEncodableKeyValuesProcessing {
    typealias Process = ([AnyEncodableKeyValue], DSONOutput) throws -> [AnyEncodableKeyValue]
    
    var preProcess: Process { get }
    var defaultProcess: Process { get }
    var postProcess: Process { get }
}

public extension AnyEncodableKeyValuesProcessing {

    // By default perform no preProcessing
    var preProcess: Process {
        return { proccessed, _ in
            return proccessed
        }
    }
    
    var defaultProcess: Process {
        return { keyValues, output in
            keyValues.sorted(by: \.key).filter { $0.allowsOutput(of: output) }
        }
    }
    
    // By default perform no postProcessing
    var postProcess: Process {
        return { proccessed, _ in
            return proccessed
        }
    }
}

public extension AnyEncodableKeyValuesProcessing {
    func process(keyValues: [AnyEncodableKeyValue], output: DSONOutput) throws -> [AnyEncodableKeyValue] {
        var keyValues = keyValues
        keyValues = try preProcess(keyValues, output)
        keyValues = try defaultProcess(keyValues, output)
        keyValues = try postProcess(keyValues, output)
        return keyValues
    }
}
