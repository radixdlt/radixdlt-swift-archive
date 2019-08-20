//
//  Font+Roboto.swift
//  SwiftUI-Wallet
//
//  Created by Alexander Cyon on 2019-08-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import SwiftUI

public extension Font {


//    /// Create a font with the body text style.
//    public static var body: Font

//    /// Create a system font with the given `style`.
//    public static func system(_ style: Font.TextStyle, design: Font.Design = .default) -> Font
//
//    /// Create a system font with the given `size`, `weight` and `design`.
//    public static func system(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font
//
//    /// Create a custom font with the given `name` and `size`.
//    public static func custom(_ name: String, size: CGFloat) -> Font

    static func roboto(
        size: CGFloat,
        weight: Font.Weight = .regular
    ) -> Font {
        let name = "Roboto-\(weight.name)"
        return .custom(name, size: size)
    }
}

public extension Font.Weight {
    var name: String {
        switch self {
        case .regular: return "Regular"
        case .bold: return "Bold"
        case .thin: return "Thin"
        default: fatalError("Add this weight.")
        }
    }
}
