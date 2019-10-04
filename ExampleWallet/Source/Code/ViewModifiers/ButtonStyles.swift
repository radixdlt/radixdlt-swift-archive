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

struct ButtonStyle: ViewModifier {

    private let color: Color
    private let enabled: Bool
    init(color: Color, enabled: Bool = true) {
        self.color = color
        self.enabled = enabled
    }

    dynamic func body(content: Content) -> some View {
        content
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .foregroundColor(Color.white)
            .background(enabled ? color : Color.black)
            .cornerRadius(5)
    }
}

extension View {
    dynamic func buttonStyleEmerald(enabled: Bool = true) -> some View {
        ModifiedContent(content: self, modifier: ButtonStyle(color: Color.Radix.emerald, enabled: enabled))
    }

    dynamic func buttonStyleSapphire(enabled: Bool = true) -> some View {
        ModifiedContent(content: self, modifier: ButtonStyle(color: Color.Radix.sapphire, enabled: enabled))
    }

    dynamic func buttonStyleRuby(enabled: Bool = true) -> some View {
          ModifiedContent(content: self, modifier: ButtonStyle(color: Color.Radix.ruby, enabled: enabled))
      }

}
