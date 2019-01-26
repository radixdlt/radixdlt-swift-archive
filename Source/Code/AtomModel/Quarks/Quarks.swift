//
//  Quarks.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Quarks: Codable, Collection, ExpressibleByArrayLiteral {
    public typealias Element = QuarkConvertible
    private let quarks: [Element]
    public init(quarks: [Element] = []) {
        self.quarks = quarks
    }
}

// MARK: - Codable
public extension Quarks {
    
    enum QuarksKey: CodingKey {
        case quarks
    }
    
    enum QuarkTypeKey: String, CodingKey {
        case type = "serializer"
    }
    
    // swiftlint:disable:next function_body_length
    init(from decoder: Decoder) throws {
        var quarkTypeContainer = try decoder.unkeyedContainer()
        var quarkDataContainer = try decoder.unkeyedContainer()
        var quarks = [QuarkConvertible]()
        while !quarkTypeContainer.isAtEnd {
            let nestedContainer = try quarkTypeContainer.nestedContainer(keyedBy: QuarkTypeKey.self)
            let quarkType = try nestedContainer.decode(QuarkTypes.self, forKey: .type)
            switch quarkType {
            case .accountableQuark: quarks.append(try quarkDataContainer.decode(AccountableQuark.self))
            case .chronoQuark: quarks.append(try quarkDataContainer.decode(ChronoQuark.self))
            case .dataQuark: quarks.append(try quarkDataContainer.decode(DataQuark.self))
            case .fungibleQuark: quarks.append(try quarkDataContainer.decode(FungibleQuark.self))
            case .identifiableQuark: quarks.append(try quarkDataContainer.decode(IdentifiableQuark.self))
            case .ownableQuark: quarks.append(try quarkDataContainer.decode(OwnableQuark.self))
            }
        }
        guard quarkTypeContainer.currentIndex == quarkDataContainer.currentIndex else {
            incorrectImplementation("Did we miss parsing something?")
        }
        self.quarks = quarks
    }
    
    func encode(to encoder: Encoder) throws {
        implementMe
    }
}

// MARK: - Collection
public extension Quarks {
    typealias Index = Array<Element>.Index
    var startIndex: Index {
        return quarks.startIndex
    }
    var endIndex: Index {
        return quarks.endIndex
    }
    subscript(position: Index) -> Element {
        return quarks[position]
    }
    func index(after index: Index) -> Index {
        return quarks.index(after: index)
    }
}

// MARK: - ExpressibleByArrayLiteral
public extension Quarks {
    init(arrayLiteral quarks: Element...) {
        self.init(quarks: quarks)
    }
}
