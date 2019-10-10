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
import SwiftUI

public extension Font {

    static var `default`: Self { .roboto(size: 18, weight: .regular) }
    
    static func roboto(
        size: CGFloat,
        weight: Font.Roboto.Weight = .regular
    ) -> Font {
        return Font.Roboto.sized(size, weight: weight)
    }

    static func gotham(
         size: CGFloat,
         weight: Font.Gotham.Weight = .medium
     ) -> Font {
         return Font.Gotham.sized(size, weight: weight)
     }
}

public extension Font {
    enum Roboto: FontConvertible {}
    enum Gotham: FontConvertible {}
}

public protocol NameOfFontWeight {
    var name: String { get }
}
public extension NameOfFontWeight where Self: RawRepresentable, RawValue == String {
    var name: String { rawValue.capitalizingFirstLetter() }
}

public protocol FontConvertible {
    static var family: String { get }
    associatedtype Weight: NameOfFontWeight
    static func sized(_ size: CGFloat, weight: Weight) -> Font
}
public extension FontConvertible {
    static func sized(_ size: CGFloat, weight: Weight) -> Font {
        let name = "\(Self.family)-\(weight.name)"
        return .custom(name, size: size)
    }
}

public extension Font.Roboto {

    static let family = "Roboto"

    enum Weight: String, NameOfFontWeight {
        case regular, bold, thin, medium, italic, light
    }
}

public extension Font.Gotham {

    static let family = "Gotham"

    enum Weight: String, NameOfFontWeight {
        case medium, bold, thin, ultra, book
    }
}
