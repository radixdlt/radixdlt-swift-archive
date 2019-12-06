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

public enum InvalidStringError: Swift.Error, Equatable, CustomStringConvertible {
    case invalidCharacters(expectedCharacterSet: CharacterSet, expectedCharacters: String, butGot: String)
    case tooManyCharacters(expectedAtMost: Int, butGot: Int)
    case tooFewCharacters(expectedAtLeast: Int, butGot: Int)
    case lengthNotMultiple(of: Int, shortOf: Int)
}

// MARK: - CustomStringConvertible
public extension InvalidStringError {
    var description: String {
        switch self {
        case .invalidCharacters(_, let allowedCharacters, let butGot):
            return "Invalid character: '\(butGot)', only allowed: \(allowedCharacters)"
        case .tooManyCharacters(let expectedAtMost, let butGot):
            return "Too many characters, expected at most: '\(expectedAtMost)', but got: '\(butGot)'"
        case .tooFewCharacters(let expectedAtLeast, let butGot):
            return "Too few characters, expected at least: '\(expectedAtLeast)', but got only: '\(butGot)'"
        case .lengthNotMultiple(let multiple, let shortOf):
            return "Length not multiple of '\(multiple)', short of '\(shortOf)' characters"
        }
    }
}

// MARK: - Equatable
public extension InvalidStringError {
    static func == (lhs: InvalidStringError, rhs: InvalidStringError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidCharacters, .invalidCharacters): return true
        case (.tooManyCharacters, .tooManyCharacters): return true
        case (.tooFewCharacters, .tooFewCharacters): return true
        case (.lengthNotMultiple, .lengthNotMultiple): return true
        default: return false
        }
    }
}

private extension NSCharacterSet {

    // https://medium.com/livefront/understanding-swifts-characterset-5a7a89a32b54
    var characters: [String] {
        /// An array to hold all the found characters
        var characters: [String] = []

        /// Iterate over the 17 Unicode planes (0..16)
        for plane: UInt8 in 0..<17 {
            /// Iterating over all potential code points of each plane could be expensive as
            /// there can be as many as 2^16 code points per plane. Therefore, only search
            /// through a plane that has a character within the set.
            if self.hasMemberInPlane(plane) {

                /// Define the lower end of the plane (i.e. U+FFFF for beginning of Plane 0)
                let planeStart = UInt32(plane) << 16
                /// Define the lower end of the next plane (i.e. U+1FFFF for beginning of
                /// Plane 1)
                let nextPlaneStart = (UInt32(plane) + 1) << 16

                /// Iterate over all possible UTF32 characters from the beginning of the
                /// current plane until the next plane.
                for char: UTF32Char in planeStart..<nextPlaneStart {

                    /// Test if the character being iterated over is part of this
                    /// `NSCharacterSet`
                    if self.longCharacterIsMember(char) {

                        /// Convert `UTF32Char` (a typealiased `UInt32`) into a
                        /// `UnicodeScalar`. Otherwise, converting `UTF32Char` directly
                        /// to `String` would turn it into a decimal representation of
                        /// the code point, not the character.
                        if let unicodeCharacter = UnicodeScalar(char) {
                            characters.append(String(unicodeCharacter))
                        }
                    }
                }
            }
        }
        return characters
    }
}

extension CharacterSet {
    var asString: String {
        let nsCharacterSet = NSCharacterSet.init(bitmapRepresentation: self.bitmapRepresentation)
        return nsCharacterSet.characters.joined()
    }
}
