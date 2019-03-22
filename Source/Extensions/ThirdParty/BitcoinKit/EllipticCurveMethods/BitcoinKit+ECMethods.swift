//
//  BitcoinKit+ECMultiplication.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import BitcoinKit

public struct EllipticCurvePoint {
    public typealias Scalar = BigUnsignedInt
    public let x: Scalar
    public let y: Scalar
}

public extension EllipticCurvePoint {
    static func decodePointFromPublicKey(_ publicKey: PublicKey) -> EllipticCurvePoint {
        let bitcoinKitPublicKey = BitcoinKit.PublicKey(bytes: publicKey.asData, network: .mainnetBTC)
        do {
            let point = try PointOnCurve.decodePointFromPublicKey(bitcoinKitPublicKey)
            return EllipticCurvePoint(point)
        } catch {
            incorrectImplementation("error: \(error)")
        }
    }
}

public extension EllipticCurvePoint {
    static func * (lhs: Scalar, rhs: EllipticCurvePoint) -> EllipticCurvePoint {
        let scalar = Scalar32Bytes(lhs)
        let point = PointOnCurve(rhs)
        do {
            let resultingPoint = try point.multiplyBy(scalar: scalar)
            return EllipticCurvePoint(resultingPoint)
        } catch {
            incorrectImplementation("error: \(error)")
        }
    }
    
    static func * (lhs: EllipticCurvePoint, rhs: Scalar) -> EllipticCurvePoint {
        return rhs * lhs
    }
}

public func * (lhs: PrivateKey, rhs: EllipticCurvePoint) -> EllipticCurvePoint {
    let scalar = EllipticCurvePoint.Scalar(lhs.scalar)
    return scalar * rhs
}

public func * (lhs: EllipticCurvePoint, rhs: PrivateKey) -> EllipticCurvePoint {
    return rhs * lhs
}

private extension EllipticCurvePoint {
    init(_ pointOnCurve: PointOnCurve) {
        self.init(
            x: Scalar(pointOnCurve.x),
            y: Scalar(pointOnCurve.y)
        )
    }
}

private extension EllipticCurvePoint.Scalar {
    init(_ scalar32Bytes: Scalar32Bytes) {
        self.init(scalar32Bytes.data)
    }
}

private extension Scalar32Bytes {
    init(_ scalar: EllipticCurvePoint.Scalar) {
        do {
            var bytes = scalar.bytes
            while bytes.length < Scalar32Bytes.expectedByteCount {
                bytes = [0x00] + bytes
            }
            try self.init(data: bytes.asData)
        } catch {
            incorrectImplementation("error: \(error), scalar hex:\n`\(scalar.hex)`")
        }
    }
}

private extension PointOnCurve {
    init(_ point: EllipticCurvePoint) {
        self.init(
            x: Scalar32Bytes(point.x),
            y: Scalar32Bytes(point.y)
        )
    }
}
