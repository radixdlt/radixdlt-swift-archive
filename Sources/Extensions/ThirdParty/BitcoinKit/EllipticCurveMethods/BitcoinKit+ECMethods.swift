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
