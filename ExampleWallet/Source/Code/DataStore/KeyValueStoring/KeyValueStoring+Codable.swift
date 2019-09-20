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

// MARK: - Codable
extension KeyValueStoring {
    func loadCodable<C>(
         forKey key: Key,
         jsonDecoder: JSONDecoder = .init()
     ) -> C? where C: Codable {
         loadCodable(C.self, forKey: key, jsonDecoder: jsonDecoder)
     }

     func loadCodable<C>(
         _ modelType: C.Type,
         forKey key: Key,
         jsonDecoder: JSONDecoder = .init()
     ) -> C? where C: Codable {

         guard
             let json: Data = loadValue(forKey: key),
             let model = try? jsonDecoder.decode(C.self, from: json)
             else { return nil }
         return model
     }

     func saveCodable<C>(
         _ model: C,
         forKey key: Key,
         options: SaveOptions = .default,
         jsonEncoder: JSONEncoder = .init(),
         notifyChange: Bool = false
     ) where C: Codable {
         do {
             let json = try jsonEncoder.encode(model)
            save(value: json, forKey: key, options: options, notifyChange: notifyChange)
         } catch {
             // TODO change to print
             fatalError("Failed to save codable, error: \(error)")
         }
     }
}
