//
//  String+JavaHashCode.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

extension Character {
    var asciiValue: UInt32? {
        return unicodeScalars.filter { $0.isASCII }.first?.value
    }
}

extension String {
    var asciiArray: [UInt32] {
        return compactMap { $0.asciiValue }
    }
    
    /// Stolen from https://stackoverflow.com/a/44413863/1311272
    func javaHashCode() -> Int32 {
        var h : Int32 = 0
        for i in asciiArray {
            h = 31 &* h &+ Int32(i)
        }
        return h
    }
}

final class JavaHash {
    static func from(_ string: String) -> Int {
        return Int(string.javaHashCode())
    }
}
