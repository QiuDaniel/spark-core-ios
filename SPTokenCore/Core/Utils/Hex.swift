//
//  Hex.swift
//  SPTokenCore
//
//  Created by SPARK-Daniel on 2020/4/14.
//  Copyright © 2020 SPARK-Daniel. All rights reserved.
//

import Foundation

public final class Hex {
    private static let prefix = "0x"
    
    static func hasHexPrefix(_ string: String) -> Bool {
        return string.hasPrefix(prefix)
    }
    
    static func isHex(_ string: String) -> Bool {
        if hasHexPrefix(string) {
            return isHex(string.substring(from: 2))
        }
        
        if string.count % 2 != 0 {
            return false
        }
        
        let regex = "^[A-Fa-f0-9]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: string)
    }
    
    static func removePrefix(_ hex: String) -> String {
        if hasHexPrefix(hex) {
            return hex.substring(from: 2)
        }
        return hex
    }
    
    static func addPrefix(_ hex: String) -> String {
        if !hasHexPrefix(hex) {
            return prefix + hex
        }
        return hex
    }
}
