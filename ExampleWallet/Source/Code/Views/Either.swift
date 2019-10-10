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

protocol NamedDestination {
    static var name: String { get }
}
extension NamedDestination {
    var name: String { Self.name }
}

struct Either<Primary, Secondary> where Primary: View, Secondary: View {
    
    @Environment(\.sizeCategory) var sizeCategory
    
    private let primary: Primary
    private let primaryName: String
    private let primaryIsAvailable: Bool
    private let primaryColor: Color
    
    private let secondary: Secondary
    private let secondaryName: String
    private let secondaryIsAvailable: Bool
    private let secondaryColor: Color
    
    init(
        _ primary: Primary,
        named primaryName: String,
        present isPrimaryAvailable: @autoclosure () -> Bool = { true }(),
        color primaryColor: Color = Color.Radix.sapphire,
        
        `or` secondary: Secondary,
        named secondaryName: String,
        present isSecondaryAvailable: @autoclosure () -> Bool = { true }(),
        color secondaryColor: Color = Color.Radix.emerald
        
    ) {
        self.primary = primary
        self.primaryName = primaryName
        self.primaryIsAvailable = isPrimaryAvailable()
        self.primaryColor = primaryColor
        
        // SECONDARY
        self.secondary = secondary
        self.secondaryName = secondaryName
        self.secondaryIsAvailable = isSecondaryAvailable()
        self.secondaryColor = secondaryColor
    }
}

extension Either where Primary: EmptyInitializable, Secondary: EmptyInitializable {
    init(
        primary primaryName: String,
        present isPrimaryAvailable: @autoclosure () -> Bool = { true }(),
        color primaryColor: Color = Color.Radix.sapphire,
        
        secondary secondaryName: String,
        present isSecondaryAvailable: @autoclosure () -> Bool = { true }(),
        color secondaryColor: Color = Color.Radix.emerald
        
    ) {
        self.init(
            .init(),
            named: primaryName,
            present: isPrimaryAvailable(),
            color: primaryColor,
            
            or: .init(),
            named: secondaryName,
            present: isSecondaryAvailable(),
            color: secondaryColor
        )
    }
}


extension Either where Primary: NamedDestination, Secondary: NamedDestination {
    init(
        _ primary: Primary,
        present isPrimaryAvailable: @autoclosure () -> Bool = { true }(),
        color primaryColor: Color = Color.Radix.sapphire,
        
        `or` secondary: Secondary,
        present isSecondaryAvailable: @autoclosure () -> Bool = { true }(),
        color secondaryColor: Color = Color.Radix.emerald
    ) {
        self.init(
            primary,
            named: Primary.name,
            present: isPrimaryAvailable(),
            color: primaryColor,
            
            or: secondary,
            named: Secondary.name,
            present: isSecondaryAvailable(),
            color: secondaryColor
        )
    }
}

extension Either: View {
    var body: some View {
        Group {
            if primaryIsAvailable && secondaryIsAvailable {
                if sizeCategory == .accessibilityLarge {
                    VStack { bothViews }
                } else {
                    HStack { bothViews }
                }
            } else if primaryIsAvailable {
                primaryView
            } else if secondaryIsAvailable {
                secondaryView
            } else {
                EmptyView()
            }
        }.padding([.leading, .trailing])
            .padding([.top, .bottom], 2)
    }
    
    private var primaryView: some View {
        NavigationLink(destination: primary) {
            Text(primaryName).buttonStyle(color: primaryColor)
        }
    }
    
    private var secondaryView: some View {
        NavigationLink(destination: secondary) {
            Text(secondaryName).buttonStyle(color: secondaryColor)
        }
    }
    
    private var bothViews: some View {
        Group {
            primaryView
            secondaryView
        }
    }
}
