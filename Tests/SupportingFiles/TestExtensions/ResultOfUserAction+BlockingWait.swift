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

extension ResultOfUserAction {
    func blockingWasSuccessful(
        timeout: TimeInterval? = .default,
        failOnTimeout: Bool = true,
        failOnErrors: Bool = true,
        function: String = #function,
        file: String = #file,
        line: Int = #line
        ) -> Bool {
        
        return self.toCompletable().blockingWasSuccessful(
            timeout: timeout,
            failOnTimeout: failOnTimeout,
            failOnErrors: failOnErrors,
            function: function, file: file, line: line
        )
        
    }
    
    func blockingAssertThrows<SpecificError>(
        error expectedError: SpecificError,
        timeout: TimeInterval? = .default
    ) where SpecificError: Swift.Error, SpecificError: Equatable {
        
        return self.toCompletable()
            .blockingAssertThrows(
                error: expectedError,
                timeout: timeout
            ) {
                
                func mapFailedToStageAction(_ failedToStageAction: FailedToStageAction) -> SpecificError? {
                    guard let failedToStageActionError = failedToStageAction.error as? SpecificError else {
                        XCTFail("Expected \(expectedError), but got error: \(failedToStageAction.error)")
                        return nil
                    }
                    return failedToStageActionError
                }
                
                if let userActionError = $0 as? ResultOfUserAction.Error {
                    
                    
                    switch userActionError {
                    case .failedToStageAction(let failedToStageAction):
                       return mapFailedToStageAction(failedToStageAction)
                    case .failedToSubmitAtom(let anySubmitAtomError):
                        guard let submitAtomError = anySubmitAtomError as? SpecificError else {
                            XCTFail("Expected \(expectedError), but got: \(anySubmitAtomError)")
                            return nil
                        }
                        return submitAtomError
                    }
                } else if let failedToStageAction = $0 as? FailedToStageAction {
                    return mapFailedToStageAction(failedToStageAction)
                } else {
                    XCTFail("Unhandled error case: \($0)")
                    return nil
                }
        }
    }
}

