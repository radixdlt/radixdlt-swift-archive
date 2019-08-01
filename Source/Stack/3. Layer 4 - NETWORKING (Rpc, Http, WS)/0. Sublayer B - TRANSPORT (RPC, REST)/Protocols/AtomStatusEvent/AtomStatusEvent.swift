/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import Foundation

public enum AtomStatusEvent: Decodable, Equatable, CustomStringConvertible, CustomDebugStringConvertible {
    case stored
    case notStored(reason: AtomNotStoredReason)
}

// MARK: CustomStringConvertible
public extension AtomStatusEvent {
    var debugDescription: String {
        switch self {
        case .stored: return "Stored"
        case .notStored(let reason): return "NotStored(reason: \(reason))"
        }
    }
    
    var description: String {
        switch self {
        case .stored: return "Stored"
        case .notStored: return "NotStored"
        }
    }
}

// MARK: Decodable
public extension AtomStatusEvent {
    enum CodingKeys: String, CodingKey {
        case atomStatus = "status"
        case dataAsJsonString = "data"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let atomStatus = try container.decode(AtomStatus.self, forKey: .atomStatus)

        switch atomStatus {
        case .stored:
            self = .stored
        default:
            
            let anyDecodable = try container.decode(AnyDecodable.self, forKey: .dataAsJsonString)
            let dataAsJsonString = String(describing: anyDecodable.value)
            
            let reasonForNotStored = AtomNotStoredReason(atomStatus: atomStatus, dataAsJsonString: dataAsJsonString)
            self = .notStored(reason: reasonForNotStored)
        }
        
    }
}

