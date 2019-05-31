//
//  BitcoinKit+ECMultiplication.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import BitcoinKit

public struct EllipticCurvePoint: Throwing {
    public typealias Scalar = BigUnsignedInt
    public let x: Scalar
    public let y: Scalar
}

public extension EllipticCurvePoint {
    enum Error: Swift.Error, Equatable {
        case multiplicationResultedInTooFewBytes(expected: Int, butGot: Int)
        case expectedUncompressedPoint
        case publicKeyContainsTooFewBytes(expected: Int, butGot: Int)
    }
}

// MARK: EllipticCurvePoint.Error + Equatable
extension EllipticCurvePoint.Error {
    public static func == (lhs: EllipticCurvePoint.Error, rhs: EllipticCurvePoint.Error) -> Bool {
        switch (lhs, rhs) {
        case (.expectedUncompressedPoint, .expectedUncompressedPoint): return true
        case (.multiplicationResultedInTooFewBytes, .multiplicationResultedInTooFewBytes): return true
        case (.publicKeyContainsTooFewBytes, .publicKeyContainsTooFewBytes): return true
        default: return false
        }
    }
}

private extension EllipticCurvePoint.Error {
    init(bitcoinKitError: PointOnCurve.Error) {
        switch bitcoinKitError {
        case .expectedUncompressedPoint: self = .expectedUncompressedPoint
        case .multiplicationResultedInTooFewBytes(let expected, let butGot): self = .multiplicationResultedInTooFewBytes(expected: expected, butGot: butGot)
        case .publicKeyContainsTooFewBytes(let expected, let butGot): self = .publicKeyContainsTooFewBytes(expected: expected, butGot: butGot)
        }
    }
}

public extension EllipticCurvePoint {
    static func decodePointFromPublicKey(_ publicKey: PublicKey) throws -> EllipticCurvePoint {
        let bitcoinKitPublicKey = BitcoinKit.PublicKey(bytes: publicKey.asData, network: .mainnetBTC)
        do {
            let point = try PointOnCurve.decodePointFromPublicKey(bitcoinKitPublicKey)
            return EllipticCurvePoint(point)
        } catch let bitcoinKitError as PointOnCurve.Error {
            throw Error(bitcoinKitError: bitcoinKitError)
        } catch { incorrectImplementation("Unhandled error: \(error)") }
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
