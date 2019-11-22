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

// From: https://github.com/ReactiveX/RxSwift/blob/master/RxBlocking/RunLoopLock.swift

let runLoopMode: CFRunLoopMode = CFRunLoopMode.defaultMode
let runLoopModeRaw = runLoopMode.rawValue

final class RunLoopLock {
    let _currentRunLoop: CFRunLoop
    
    let _calledRun = AtomicInt(0)
    let _calledStop = AtomicInt(0)
    var _timeout: TimeInterval?
    
    init(timeout: TimeInterval?) {
        self._timeout = timeout
        self._currentRunLoop = CFRunLoopGetCurrent()
    }
    
    func dispatch(_ action: @escaping () -> Void) {
        CFRunLoopPerformBlock(self._currentRunLoop, runLoopModeRaw) {
            action()
        }
        CFRunLoopWakeUp(self._currentRunLoop)
    }
    
    func stop() {
        if decrement(self._calledStop) > 1 {
            return
        }
        CFRunLoopPerformBlock(self._currentRunLoop, runLoopModeRaw) {
            CFRunLoopStop(self._currentRunLoop)
        }
        CFRunLoopWakeUp(self._currentRunLoop)
    }
    
    func run() throws {
        if increment(self._calledRun) != 0 {
            fatalError("Run can be only called once")
        }
        if let timeout = self._timeout {
            switch CFRunLoopRunInMode(runLoopMode, timeout, false) {
            case .finished:
                return
            case .handledSource:
                return
            case .stopped:
                return
            case .timedOut:
                throw RunLoopError.timeout
            default:
                return
            }
        } else {
            CFRunLoopRun()
        }
    }
}

enum RunLoopError: Swift.Error {
    case timeout
}
