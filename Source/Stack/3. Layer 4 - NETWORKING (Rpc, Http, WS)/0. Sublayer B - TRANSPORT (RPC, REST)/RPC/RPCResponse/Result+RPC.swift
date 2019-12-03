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

internal typealias RPCResult<Model: Decodable> = Swift.Result<RPCResponse<Model>, RPCError>

extension Result: Decodable where Success: Decodable, Failure == RPCError {
    
    enum CodingKeys: String, CodingKey {
        case result, params, error
    }
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let singleValueContainer = try decoder.singleValueContainer()
        
        if keyedContainer.contains(.params) || keyedContainer.contains(.result) {
            do {
                self = .success(try singleValueContainer.decode(Success.self))
            } catch let decodingError as DecodingError {
                let anyDecodable = try singleValueContainer.decode(AnyDecodable.self)
//                let jsonString = String(describing: anyDecodable.value)
                
                let successTypeString = "\(type(of: Success.self))"
                
                let error: RPCError = .failedToDecodeResponse(
                    decodingErrorAsString: decodingError.localizedDescription,
                    asType: successTypeString
                )
                
                self = .failure(error)
            } catch {
                incorrectImplementation("Covered by RPCResponse `init(from: Decoder)`")
            }
        } else if keyedContainer.contains(.error) {
            do {
                self = .failure(try singleValueContainer.decode(RPCError.self))
            } catch {
                 incorrectImplementation("Covered by RPCError `init(from: Decoder)`")
            }
        } else {
            let anyDecodable = try singleValueContainer.decode(AnyDecodable.self)
            let jsonString = String(describing: anyDecodable.value)
//            self = .failure(RPCError.unrecognizedJson(jsonString: jsonString))
            fatalError("got unrecognized json: \(jsonString)")
        }
    }
}
