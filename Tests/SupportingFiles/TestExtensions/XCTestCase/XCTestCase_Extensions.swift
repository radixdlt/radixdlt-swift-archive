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
@testable import RadixSDK
import XCTest

extension XCTestCase {
    
    var testBundle: Bundle {
        return Bundle(for: type(of: self))
    }
    
    @discardableResult
    func decodeOrFail<D>(jsonString: String, to toType: D.Type? = nil, _ file: String = #file, _ line: Int = #line) -> D? where D: Decodable & RadixModelTypeStaticSpecifying {
        return decodeOrFail(jsonData: jsonString.toData(), to: toType)
    }
    
    @discardableResult
    func decodeOrFail<D>(jsonData: Data, to toType: D.Type? = nil, _ file: String = #file, _ line: Int = #line) -> D? where D: Decodable & RadixModelTypeStaticSpecifying {
        do {
            return try decode(D.self, jsonData: jsonData)
        } catch {
            XCTFail("error: \(error), file: \(file), line: \(line)")
            return nil
        }
    }
    
    @discardableResult
    func decode<D>(_ type: D.Type, jsonString: String) throws -> D where D: Decodable & RadixModelTypeStaticSpecifying {
        return try decode(D.self, jsonData: jsonString.toData())
    }
    
    @discardableResult
    func decode<D>(_ type: D.Type, jsonData: Data) throws -> D where D: Decodable & RadixModelTypeStaticSpecifying {
        return try RadixJSONDecoder().decode(D.self, from: jsonData)
    }
    
    func jsonOrFail<EncodableModel>(_ model: EncodableModel)  -> Data? where EncodableModel: Encodable {
        do {
            return try RadixJSONEncoder().encode(model)
        } catch {
            XCTFail("Failed to encode model, error: \(error)")
            return nil
        }
    }
    
    func jsonStringOrFail<EncodableModel>(_ model: EncodableModel)  -> String? where EncodableModel: Encodable {
        guard let encodedJson = jsonOrFail(model) else {
            return nil
        }
        return encodedJson.toString()
    }
    
    func dsonOrFail<EncodableModel>(_ model: EncodableModel, output: DSONOutput = .default)  -> Data? where EncodableModel: DSONEncodable {
        do {
            return try model.toDSON(output: output)
        } catch {
            XCTFail("Failed to encode model, error: \(error)")
            return nil
        }
    }
    
    func dsonHexStringOrFail<EncodableModel>(_ model: EncodableModel, output: DSONOutput = .default)  -> String? where EncodableModel: DSONEncodable {
        guard let encodedDson = dsonOrFail(model, output: output) else {
            return nil
        }
        return encodedDson.hex
    }
}

extension Data {
    func toString() -> String {
        return String(data: self)
    }
}
