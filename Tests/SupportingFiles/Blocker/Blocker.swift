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

private let timeoutInSecondsEnoughForPOW: Int = 10
extension TimeInterval {
    static var enoughForPOW: Self { .init(timeoutInSecondsEnoughForPOW) }
}
extension DispatchTimeInterval {
    static var enoughForPOW: Self { .seconds(timeoutInSecondsEnoughForPOW) }
}


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

// "Prefix"
extension Publishers.Output: SliceOfOutputPublisher {
    var sizeOfSlice: Int { range.count }
}

extension Publishers.IgnoreOutput: SliceOfOutputPublisher {
    var sizeOfSlice: Int { 0 }
}


protocol BlockerErrorConvertible: Swift.Error {
    static func gotZeroValues(butRequested: Int) -> Self
}

enum BlockerError<Output, Failure>: BlockerErrorConvertible where Failure: Swift.Error {
    case timedOut(after: DispatchTimeInterval, outputUntilTimeout: [Output])
    case notEnoughValuesPublished(requested: Int, butOnlyGot: Int, specifically: [Output])
    case publisherError(Failure)
}
extension BlockerError {
    static func gotZeroValues(butRequested requested: Int) -> Self {
        return Self.notEnoughValuesPublished(requested: requested, butOnlyGot: 0, specifically: [])
    }
}
extension BlockerError: Equatable where Output: Equatable, Failure: Equatable {
    
}

//protocol AnyBlocker: AnyObject {}
final class Blocker<Output, Failure> where Failure: Swift.Error {
    
    typealias Error = BlockerError<Output, Failure>
    
    private let publisherToBlock: AnyPublisher<Output, Error>
    
    typealias SpecifyNumberOfExpectedOutputtedValues<FromPublisher> = (FromPublisher) -> (SliceOfOutput<Output, Failure>) where FromPublisher: Publisher, FromPublisher.Failure == Failure
    
    private let specifiedNumberOfOutputtedValues: Int
    
    // Cancellable which is not used for now, but holds the subscription to the publisher
    private var cancellables = Set<AnyCancellable>()
    
    var result: Result<[Output], Error>?
    
    deinit {
        print("☣️ Blocker deinit")
    }
    
    fileprivate init<P>(
        publisherToBlock: P,
        specifiedNumberOfOutputtedValues: Int
    )
        where P: Publisher,
        P.Failure == Failure,
        P.Output == Output
    {
        self.specifiedNumberOfOutputtedValues = specifiedNumberOfOutputtedValues

        self.publisherToBlock = publisherToBlock
            .mapError { Error.publisherError($0) }
            .eraseToAnyPublisher()
    }
}

private extension Blocker {
    convenience init<From>(
        _ publisherToBlock: From,
        sliceOutput: SpecifyNumberOfExpectedOutputtedValues<From>
    )
        where
        From: Publisher,
        From.Failure == Failure
    {
        let slicedOutput = sliceOutput(publisherToBlock)
        
        self.init(
            publisherToBlock: slicedOutput.underlyingPublisher(),
            specifiedNumberOfOutputtedValues: slicedOutput.sizeOfSlice
        )
    }
}

extension Blocker {
    func blockingWasSuccessful(timeout: DispatchTimeInterval = .ms100, handleFailure: ((Error) -> Void)? = nil) -> Bool {
        let blockingResult = blocking(timeout: timeout)
        switch blockingResult {
        case .failure(let error):
            handleFailure?(error)
            return false
        case .success: return true
        }
    }
    
    func blocking(timeout: DispatchTimeInterval = .ms100) -> Result<[Output], Error> {
        
        var outputs = [Output]()
        let result: Result<[Output], Error>
        var timeoutError: Swift.Error?
        let lock = RunLoopLock(timeout: timeout.asSeconds!)
        
        lock.dispatch { [unowned self] in
            self.publisherToBlock
                .sink(
                    receiveCompletion: { _ in lock.stop() },
                    receiveValue: { outputs.append($0) }
            )
                .store(in: &self.cancellables)
            

        }
        
        do {
            try lock.run()
        } catch {
            timeoutError = error
        }
        
        if timeoutError != nil {
            result = .failure(.timedOut(after: timeout, outputUntilTimeout: outputs))
        } else {
            if outputs.count == specifiedNumberOfOutputtedValues {
                result = .success(outputs)
            } else {
                if outputs.count > specifiedNumberOfOutputtedValues {
                    incorrectImplementationShouldAlwaysBeAble(to: "To correct or FEWER number of outputted values, something is wrong with implementation of `SpecifyNumberOfExpectedOutputtedValues`")
                }
                result = .failure(
                    .notEnoughValuesPublished(
                        requested: specifiedNumberOfOutputtedValues,
                        butOnlyGot: outputs.count,
                        specifically: outputs
                    )
                )
            }
        }
        print("☑️ blocker done, result: \(result)")
        self.result = result
        return result
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
    
    static func prefix<P>(_ specifiedNumberOfOutputtedValues: Int, from publisher: P) -> Blocker
        where P: Publisher,
        P.Output == Output,
        P.Failure == Failure
    {
        self.init(publisher) { SliceOfOutput(from: $0.prefix(specifiedNumberOfOutputtedValues)) }
    }
    
    static func ignoreOutput<P>(of publisher: P) -> Blocker
        where
        Output == Never,
        P: Publisher & SliceOfOutputPublisher,
        
        P.Failure == Failure
    {
        self.init(publisherToBlock: publisher.ignoreOutput(), specifiedNumberOfOutputtedValues: 0)
    }
    
}

extension Publisher where Self: SliceOfOutputPublisher {
    fileprivate func asBlocker() -> Blocker<Output, Failure> {
        Blocker(self) { SliceOfOutput(from: $0) }
    }
    
    func blockingResult(timeout: DispatchTimeInterval = .ms100) -> Result<[Output], Blocker<Output, Failure>.Error> {
        let blocker = asBlocker()
        return blocker.blocking(timeout: timeout)
    }
}

typealias BlockingResult<Output, Failure> = Result<Output, BlockerError<Output, Failure>> where Failure: Swift.Error

extension Publisher where Output: Sequence, Failure == Never {
   
    func blockingListResultFirst(
        timeout: DispatchTimeInterval = .ms100
    ) -> BlockingResult<Output.Element, Failure> {

        let blocker = Blocker(self.flattenSequence()) {
            SliceOfOutput<Output.Element, Failure>(
                from: $0.first()
            )
        }

        return blocker.blocking(timeout: timeout)
            .flatMapFirst()
    }
    
    func blockingListOutputFirst(
        timeout: DispatchTimeInterval = .ms100
    ) throws -> Output.Element {
        try blockingListResultFirst(timeout: timeout).get()
    }
}

extension Publisher {
        
    func blockingOutputFirst(
        timeout: DispatchTimeInterval = .ms100
    ) throws -> Output {
        
        try self
            .first()
            .blockingResult(timeout: timeout)
            .flatMapFirst()
        .get()
    }
}


struct NoOutput: Equatable {}

extension Publisher where Self: SliceOfOutputPublisher {
    func blockingIgnoreOutput(
        timeout: DispatchTimeInterval = .ms100
    ) -> BlockingResult<NoOutput, Failure> {
        
        let blocker = Blocker.ignoreOutput(of: self)
        let result = blocker.blocking(timeout: timeout)
        switch result {
        case .failure(let error):
            switch error {
            case .timedOut: return .failure(.timedOut(after: timeout, outputUntilTimeout: []))
            default: incorrectImplementation("Expected error to be timeout, but got: \(error)")
            }
        case .success: return .success(NoOutput())
        }
    }
    
    func blockingIgnoreOutputSuccess(
        timeout: DispatchTimeInterval = .ms100
    ) -> Bool {
        guard case .success = blockingIgnoreOutput(timeout: timeout) else { return false }
        return true
    }
}


private extension Result where Success: Sequence, Failure: BlockerErrorConvertible {
    func flatMapFirst() -> Result<Success.Element, Failure> {
        return self.flatMap { (successSequence: Success) -> Result<Success.Element, Failure> in
            let outputs = [Success.Element](successSequence)
            guard let firstOutput = outputs.first else {
                return Result<Success.Element, Failure>.failure(Failure.gotZeroValues(butRequested: 1))
            }
            return Result<Success.Element, Failure>.success(firstOutput)
        }
    }
}

extension DispatchTimeInterval {
    static var ms100: Self { .milliseconds(100) }
}
