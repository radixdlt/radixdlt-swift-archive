//
//  ButtonStyles.swift
//  SwiftUI-Wallet
//
//  Created by Alexander Cyon on 2019-08-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import SwiftUI

struct ButtonStyle: ViewModifier {

    private let color: Color
    private let enabled: () -> Bool
    init(color: Color, enabled: @escaping () -> Bool = { true }) {
        self.color = color
        self.enabled = enabled
    }

    dynamic func body(content: Content) -> some View {
        content
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .foregroundColor(Color.white)
            .background(enabled() ? color : Color.black)
            .cornerRadius(5)
    }
}

extension View {
    dynamic func buttonStyleEmerald(enabled: @escaping () -> Bool = { true }) -> some View {
        ModifiedContent(content: self, modifier: ButtonStyle(color: Color.Radix.emerald, enabled: enabled))
    }

    dynamic func buttonStyleSaphire(enabled: @escaping () -> Bool = { true }) -> some View {
        ModifiedContent(content: self, modifier: ButtonStyle(color: Color.Radix.saphire, enabled: enabled))
    }

}
