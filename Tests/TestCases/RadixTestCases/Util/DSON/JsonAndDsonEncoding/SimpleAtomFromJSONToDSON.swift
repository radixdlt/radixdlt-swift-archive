//
//  SimpleAtomFromJSONToDSON.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-15.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Quick
import Nimble

public extension CBOR {
    static func decode(hex: String) -> String? {
        guard let hexString = try? HexString(hexString: hex) else {
            return nil
        }
        do {
            guard let cbor = try CBOR.decode(hexString.bytes) else {
                return nil
            }
            switch cbor {
            case .utf8String(let string): return string
            default: return "\(cbor)"
            }
        } catch {
            return nil
        }
    }
    static func decodeAsString(hex: String) -> String? {
        guard let hexString = try? HexString(hexString: hex) else {
            return nil
        }
        do {
            guard let cbor = try CBOR.decode(hexString.bytes) else {
                return nil
            }
            switch cbor {
            case .utf8String(let string): return string
            default:
                print("not utf8String, was: \(cbor)"); return nil
            }
        } catch {
            return nil
        }
    }
}


extension StringProtocol where Index == String.Index {
    func index(of string: Self, options: String.CompareOptions = []) -> Range<Index>? {
        return range(of: string, options: options)
    }
    func endIndex(of string: Self, options: String.CompareOptions = []) -> Range<Index>? {
        return range(of: string, options: options)
    }
    func indexes(of string: Self, options: String.CompareOptions = []) -> [Range<Index>] {
        var result = [Range<Index>]()
        var start = startIndex
        while start < endIndex,
            let range = self[start..<endIndex].range(of: string, options: options) {
                result.append(range)
                start = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    func ranges(of string: Self, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while start < endIndex,
            let range = self[start..<endIndex].range(of: string, options: options) {
                result.append(range)
                start = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

class SimpleAtomFromJSONToDSONSpec: QuickSpec {
    
    override func spec() {
        let atom: Atom = model(from: jsonString)
        describe("Deserialized Atom") {
            it("should contain two empty particlegroups") {
                expect(atom.particleGroups.count).to(equal(1))
            }
        }

        describe("DSON encoding") {
            describe("DSON Hex") {
                let dson = try! atom.toDSON(output: .all)
                let dsonHex = dson.hex

                it("should serialize into correct DSON") {
                    expect(dsonHex).to(equal(expectedDsonHex))
                }
            }
        }
    }
}

private let expectedDsonHex = "bf686d65746144617461bf6974696d657374616d706d31343838333236343030303030ff6e7061727469636c6547726f75707381bf6a73657269616c697a65723a03ff3c666776657273696f6e1864ff6a73657269616c697a65721a001ed1516a7369676e617475726573bf78203731633363326663396665653733623133636164303832383030613664306465bf617258210125150b1a4996cf1571d00b4ef0d62667402a6e2ea11bf563e867a80774ef1c05617358210129b282c87c3d1983fa1328dbc9069c917b45e078fb0a05f67e64e5b60e555fd16a73657269616c697a65723a19ea57676776657273696f6e1864ffff6776657273696f6e1864ff"

private let signatureHuidHex = "71c3c2fc9fee73b13cad082800a6d0de"

private let jsonString = """
{
    "metaData": {
        "timestamp": ":str:1488326400000"
    },
    "particleGroups": [
        {
            "particles": [],
            "serializer": -67058791,
            "\(jsonKeyVersion)": \(serializerVersion)
        }
    ],
    "serializer": 2019665,
    "signatures": {
        "\(signatureHuidHex)": {
            "r":":byt:JRULGkmWzxVx0AtO8NYmZ0Aqbi6hG/Vj6GeoB3TvHAX=",
            "s":":byt:KbKCyHw9GYP6EyjbyQackXtF4Hj7CgX2fmTltg5VX9H=",
            "serializer": -434788200,
            "\(jsonKeyVersion)": \(serializerVersion)
        }
    },
    "\(jsonKeyVersion)": \(serializerVersion)
}
"""
