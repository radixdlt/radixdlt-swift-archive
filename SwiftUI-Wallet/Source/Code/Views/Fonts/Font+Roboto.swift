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
