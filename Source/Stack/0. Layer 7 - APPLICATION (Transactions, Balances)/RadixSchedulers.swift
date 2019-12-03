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
import Combine

internal enum RadixSchedulers {}

internal extension RadixSchedulers {
    
    typealias MainThread = DispatchQueue
    typealias BackgroundThread = DispatchQueue
     
    static let backgroundScheduler: BackgroundThread = .global(qos: .utility)
    static let mainThreadScheduler: MainThread = .main
}

internal extension RadixSchedulers {
    
    static func delay<P>(
        publisher: P,
        for delay: DispatchTimeInterval,
        dispatchQueue: DispatchQueue
    ) -> AnyPublisher<P.Output, P.Failure> where P: Publisher {
        return publisher.delay(
            for: DispatchQueue.SchedulerTimeType.Stride(delay),
            scheduler: dispatchQueue
        )
        .eraseToAnyPublisher()
    }
    
    enum SchedulerType: Int, Equatable {
        case mainThread, backgroundThread
    }
}

internal extension Publisher {
    
    func delay(
        for delay: DispatchTimeInterval,
        on schedulerType: RadixSchedulers.SchedulerType
    ) -> AnyPublisher<Output, Failure> {
        
        let queue: DispatchQueue = schedulerType == .mainThread ? RadixSchedulers.mainThreadScheduler : RadixSchedulers.backgroundScheduler
            
        return RadixSchedulers.delay(publisher: self, for: delay, dispatchQueue: queue)
    }
}

extension DispatchTimeInterval {
    var asSeconds: TimeInterval? {
        switch self {
        case .seconds(let secondsAsInt):
            return TimeInterval(secondsAsInt)
        case .milliseconds(let milliSecondsAsInt):
            return TimeInterval(milliSecondsAsInt) / 1_000
        case .microseconds(let microSecondsAsInt):
            return TimeInterval(microSecondsAsInt) / 1_000_000
        case .nanoseconds(let nanoSecondsAsInt):
            return TimeInterval(nanoSecondsAsInt) / 1_000_000_000
        case .never: return nil
        @unknown default:
            incorrectImplementation("Have not yet handled new enum case: \(self)")
        }
    }
}

extension RadixSchedulers {
    static func timer<MapTo>(
        publishEvery interval: TimeInterval,
        _ transform: @escaping () -> MapTo
    ) -> AnyPublisher<MapTo, Never> {
        
        return Timer.publish(
            every: interval,
            on: RunLoop.main,
            in: .common
        )
            .autoconnect()^
            .receive(on: RadixSchedulers.mainThreadScheduler)
            .map { _ in transform() }
            .eraseToAnyPublisher()
    }
}

extension Thread {
    
    var threadName: String {
        func nameOf(queue: DispatchQueue?) -> String {
            let labelOfCurrentQueue = __dispatch_queue_get_label(nil)
            guard let name = String(cString: labelOfCurrentQueue, encoding: .utf8) else {
                fatalError("fail")
            }
            return name
        }
        
        let nameOfRadixBackgroundThread = nameOf(queue: RadixSchedulers.backgroundScheduler)
        let nameOfRadixMainThread = nameOf(queue: RadixSchedulers.mainThreadScheduler)
        let nameOfCurrent = nameOf(queue: nil)
        
        if nameOfCurrent == nameOfRadixBackgroundThread {
            return "background"
        } else if nameOfCurrent == nameOfRadixMainThread {
            return "main"
        } else {
            return "Other thread: \(nameOfCurrent)"
        }
    }
}
