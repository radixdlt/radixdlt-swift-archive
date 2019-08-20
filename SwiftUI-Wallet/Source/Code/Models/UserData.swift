//
//  UserData.swift
//  SwiftUI-Wallet
//
//  Created by Alexander Cyon on 2019-08-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import SwiftUI

final class UserData: ObservableObject {
    @Published var hasAgreedToTermsAndConditions = false
    @Published var hasAgreedToPrivacyPolicy = false
}
