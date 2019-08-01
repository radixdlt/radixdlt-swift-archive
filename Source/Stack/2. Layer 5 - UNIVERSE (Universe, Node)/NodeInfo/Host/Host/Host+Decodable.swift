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

// MARK: - Decodable
public extension Host {
    enum CodingKeys: String, CodingKey {
        case domain = "ip"
        case port
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let portValue = try container.decode(Int.self, forKey: .port)
        let port: Port
        do {
            port = try Port(unvalidated: portValue)
        } catch let error as Port.Error {
            throw Error.badPort(error)
        } catch {
            unexpectedlyMissedToCatch(error: error)
        }
        
        let domain = try container.decode(StringValue.self, forKey: .domain).stringValue
        
        try self.init(domain: domain, port: port)
    }
}

// MARK: - Throwing
public extension Host {
    enum Error: Swift.Error, Equatable {
        case badPort(Port.Error)
        case locationEmpty
    }
}
