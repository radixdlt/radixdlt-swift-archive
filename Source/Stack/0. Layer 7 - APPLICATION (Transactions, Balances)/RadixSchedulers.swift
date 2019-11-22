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
    typealias MainThreadScheduler = RunLoop
    typealias BackgroundScheduler = DispatchQueue
    
    static let backgroundScheduler: BackgroundScheduler = .global(qos: .utility)
    static let mainThreadScheduler: MainThreadScheduler = .main
}

internal extension RadixSchedulers {
    static func mainScheduler(time: DispatchTimeInterval) -> MainThreadScheduler.SchedulerTimeType.Stride {
        guard let seconds: Double = time.asSeconds else { incorrectImplementation("Fix time logic") }
        return .seconds(seconds)
    }
    
    static func backgroundScheduler(time: DispatchTimeInterval) -> BackgroundScheduler.SchedulerTimeType.Stride {
        return BackgroundScheduler.SchedulerTimeType.Stride(time)
    }
}

internal extension RadixSchedulers {
    enum SchedulerType {
        case mainThread, backgroundThread
    }
    
    static func delay<P>(
        publisher: P,
        for delay: DispatchTimeInterval,
        on schedulerType: SchedulerType
    ) -> AnyPublisher<P.Output, P.Failure> where P: Publisher {
        
        switch schedulerType {

        case .mainThread:
            return publisher.delay(
                for: RadixSchedulers.mainScheduler(time: delay),
                scheduler: RadixSchedulers.mainThreadScheduler
            )
            .eraseToAnyPublisher()
            
        case .backgroundThread:
            return publisher.delay(
                for: RadixSchedulers.backgroundScheduler(time: delay),
                scheduler: RadixSchedulers.backgroundScheduler
            )
            .eraseToAnyPublisher()
        }
    }
}

internal extension Publisher {
    func delay(
        for delay: DispatchTimeInterval,
        on schedulerType: RadixSchedulers.SchedulerType
    ) -> AnyPublisher<Output, Failure> {
        return RadixSchedulers.delay(publisher: self, for: delay, on: schedulerType)
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
