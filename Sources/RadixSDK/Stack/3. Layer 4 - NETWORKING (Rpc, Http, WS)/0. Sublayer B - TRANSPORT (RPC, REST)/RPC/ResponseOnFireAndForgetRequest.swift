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

/// Used in RPC for CombineCompletable requests, where we just care if the request did not result in error, but we don't care about anything else.
internal struct ResponseOnFireAndForgetRequest: Decodable {
    
    public init (from decoder: Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let anyDecodable = try singleValueContainer.decode(AnyDecodable.self)
        guard let json = anyDecodable.value as? JSON else {
            incorrectImplementation("should be JSON")
        }
        if let anySuccessValue = json["success"] {
            guard let successValue = anySuccessValue as? Bool, case let wasSuccessful = successValue else {
                incorrectImplementation("should be bool")
            }
            if wasSuccessful {
                // ALL OK!
            } else {
                incorrectImplementation("expected error...")
            }
        } else if let anyErrorValue = json["error"] {
            throw RPCError.unrecognizedJson(jsonString: String(describing: anyErrorValue))
        }
        
    }
}
