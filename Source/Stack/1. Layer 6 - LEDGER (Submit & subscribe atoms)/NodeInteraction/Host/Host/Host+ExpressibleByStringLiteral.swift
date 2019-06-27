//
//  Host+ExpressibleByStringLiteral.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// MARK: - ExpressibleByStringLiteral
extension Host: ExpressibleByStringLiteral {}
public extension Host {
    init(stringLiteral string: String) {
        if let asLocalhost = Host.fromStringAsLocalhost(string) {
            self = asLocalhost
        } else if let asDomains = Host.fromStringAsDomains(string) {
            self = asDomains
        } else if let asIp = Host.fromStringAsIPAddress(string) {
            self = asIp
        } else {
            fatalError("Failed to create Host from string: `\(string)`")
        }
        
    }
    
    // swiftlint:disable:next function_body_length
    static func fromString(
        _ string: String,
        defaultToPort defaultPort: Port = .nodeFinder,
        hostValidator: @escaping ((String) -> Bool) = { _ in true }
    ) -> Host? {
        
        let validatingHost: (String) -> String? = {
            guard hostValidator($0) else {
                return nil
            }
            return $0
        }
        
        let (base, scheme) = string.removingScheme()
        let components = base.components(separatedBy: ":")
        let schemeOrEmpty = scheme ?? ""
        let host = schemeOrEmpty + base
        if components.count == 2 {
            let hostWithPortRemoved = components[0]
            var port: Port = defaultPort
            if let portFromStringAsInt = Int(components[1]), let portFromInt = try? Port(unvalidated: portFromStringAsInt) {
                port = portFromInt
            }
            guard let validatedHost = validatingHost(hostWithPortRemoved) else {
                return nil
            }
            return try? Host(domain: validatedHost, port: port)
        } else if components.count == 1 {
            guard let validatedHost = validatingHost(host) else {
                return nil
            }
            return try? Host(domain: validatedHost, port: defaultPort)
        } else {
            incorrectImplementation("String should not have contained more than one colon")
        }
    }
    
    static func fromStringAsLocalhost(_ string: String) -> Host? {
        return fromString(string) { $0 == String.localhost }
    }
    
    static func fromStringAsIPAddress(_ string: String) -> Host? {
        return fromString(string) { $0.components(separatedBy: ".").compactMap({ UInt8($0) }).count == 4 }
    }
    
    static func fromStringAsDomains(_ string: String) -> Host? {
        return fromString(string)
    }
}

extension String {
    func removingScheme() -> (String, String?) {
        var copy = self
        func remove(scheme: String) -> String? {
            // swiftlint:disable:next force_unwrap
            let components = copy.components(separatedBy: "\(scheme)://")
            if components.count == 2 {
                copy = components[1]
                return components[0] // scheme
            } else if components.count == 1 {
                copy = components[0]
                return nil
            } else {
                incorrectImplementation("Multiple scheme found")
            }
        }
        var schemeFound: String?
        for schemeToLookFor in  ["wss", "ws", "https", "https"] {
            if let schemeFoundNew = remove(scheme: schemeToLookFor) {
                if schemeFound != nil {
                    incorrectImplementation("multiple schemes found")
                }
                schemeFound = schemeFoundNew
            }
        }
        return (copy, schemeFound)
    }
}
