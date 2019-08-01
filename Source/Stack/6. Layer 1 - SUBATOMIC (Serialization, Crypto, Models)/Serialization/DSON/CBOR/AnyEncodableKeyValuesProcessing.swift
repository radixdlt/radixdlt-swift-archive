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
