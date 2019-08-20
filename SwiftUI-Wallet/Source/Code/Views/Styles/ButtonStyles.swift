//
//  ButtonStyles.swift
//  SwiftUI-Wallet
//
//  Created by Alexander Cyon on 2019-08-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import SwiftUI

struct ButtonStyleEmerald: ViewModifier {

    private let enabled: () -> Bool

    init(enabled: @escaping () -> Bool) {
        self.enabled = enabled
    }

    dynamic func body(content: Content) -> some View {
        content
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .foregroundColor(Color.white)
            .background(enabled() ? Color.Radix.emerald : Color.black)
            .cornerRadius(5)
    }
}

extension View {
    dynamic func buttonStyleEmerald(enabled: @escaping () -> Bool) -> some View {
        ModifiedContent(content: self, modifier: ButtonStyleEmerald(enabled: enabled))
    }
}
