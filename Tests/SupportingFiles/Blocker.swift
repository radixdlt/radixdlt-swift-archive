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
import XCTest
@testable import RadixSDK
import Combine

protocol SliceOfOutputPublisher {
    var sizeOfSlice: Int { get }
}

struct SliceOfOutput<Output, Failure>: SliceOfOutputPublisher where Failure: Swift.Error {
    
    private let anyPublisher: AnyPublisher<Output, Failure>
    internal let sizeOfSlice: Int
    
    init<Concrete>(from concrete: Concrete)
        where
        Concrete: SliceOfOutputPublisher & Publisher,
        Concrete.Output == Output,
        Concrete.Failure == Failure
    {
        
        self.sizeOfSlice = concrete.sizeOfSlice
        self.anyPublisher = concrete.eraseToAnyPublisher()
    }
    
    func underlyingPublisher() -> AnyPublisher<Output, Failure> {
        anyPublisher
    }
}

extension Publishers.First: SliceOfOutputPublisher {
    var sizeOfSlice: Int { 1 }
}


extension Publishers.Last: SliceOfOutputPublisher {
    var sizeOfSlice: Int { 1 }
}

extension Publishers.Output: SliceOfOutputPublisher {
    var sizeOfSlice: Int { range.count }
}

final class Blocker<Output, Failure> where Failure: Swift.Error {
    enum Error: Swift.Error {
        case timedOut(after: DispatchTimeInterval, outputUntilTimeout: [Output])
        case notEnoughValuesPublished(requested: Int, butOnlyGot: Int, specifically: [Output])
        case publisherError(Failure)
    }
    
    private let publisherToBlock: AnyPublisher<Output, Error>
    
    typealias SpecifyNumberOfExpectedOutputtedValues<P> = (P) -> (SliceOfOutput<Output, Failure>) where P: Publisher, P.Output == Output, P.Failure == Failure
    
    private let specifiedNumberOfOutputtedValues: Int
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    // Cancellable which is not used for now, but holds the subscription to the publisher
    private var cancellable: Cancellable?
    
    private init<P>(
        _ publisherToBlock: P,
        sliceOutput: SpecifyNumberOfExpectedOutputtedValues<P>// = { SliceOfOutput(from: $0.first()) }
    )
        where P: Publisher,
        P.Output == Output,
        P.Failure == Failure
    {
        let slicedOutput = sliceOutput(publisherToBlock)
        
        self.specifiedNumberOfOutputtedValues = slicedOutput.sizeOfSlice
        
        self.publisherToBlock = slicedOutput
            .underlyingPublisher()
            .mapError { Error.publisherError($0) }
            .eraseToAnyPublisher()
    }
}

extension Blocker {
    func blockingWasSuccessful(timeout: DispatchTimeInterval = .enoughForPOW, handleFailure: ((Error) -> Void)? = nil) -> Bool {
        let blockingResult = blocking(timeout: timeout)
        switch blockingResult {
        case .failure(let error):
            handleFailure?(error)
            return false
        case .success: return true
        }
    }
    
    func blocking(timeout: DispatchTimeInterval = .enoughForPOW) -> Result<[Output], Error> {
        
        var outputs = [Output]()
        
        self.cancellable = self.publisherToBlock
            .sink(
                receiveCompletion: { [unowned semaphore] _ in semaphore.signal() },
                receiveValue: { outputs.append($0) }
        )
        
        let timeoutResult: DispatchTimeoutResult = semaphore.wait(timeout: .now() + timeout)
        
        switch timeoutResult {
        case .timedOut:
            return .failure(.timedOut(after: timeout, outputUntilTimeout: outputs))
        case .success:
            guard outputs.count == specifiedNumberOfOutputtedValues else {
                if outputs.count > specifiedNumberOfOutputtedValues {
                    incorrectImplementationShouldAlwaysBeAble(to: "To correct or FEWER number of outputted values, something is wrong with implementation of `SpecifyNumberOfExpectedOutputtedValues`")
                }
                return .failure(
                    .notEnoughValuesPublished(
                        requested: specifiedNumberOfOutputtedValues,
                        butOnlyGot: outputs.count,
                        specifically: outputs
                    )
                )
            }
            return .success(outputs)
        }
    }
    
}

extension Blocker {
    static func first<P>(of publisher: P) -> Blocker
        where P: Publisher,
        P.Output == Output,
        P.Failure == Failure
    {
        self.init(publisher) { SliceOfOutput(from: $0.first()) }
    }
    
    static func last<P>(of publisher: P) -> Blocker
        where P: Publisher,
        P.Output == Output,
        P.Failure == Failure
    {
        self.init(publisher) { SliceOfOutput(from: $0.last()) }
    }
    
    static func prefix<P>(_ specifiedNumberOfOutputtedValues: Int, from publisher: P) -> Blocker
        where P: Publisher,
        P.Output == Output,
        P.Failure == Failure
    {
        self.init(publisher) { SliceOfOutput(from: $0.prefix(specifiedNumberOfOutputtedValues)) }
    }
}
