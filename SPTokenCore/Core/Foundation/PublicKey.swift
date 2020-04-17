//
//  PublicKey.swift
//  SPTokenCore
//
//  Created by SPARK-Daniel on 2020/4/15.
//  Copyright © 2020 SPARK-Daniel. All rights reserved.
//

import Foundation

public struct PublicKey: Hashable, CustomStringConvertible {
    
    /// Compressed public key size.
    public static let compressedSize = 33
    
    /// Uncompressed public key size.
    public static let uncompressedSize = 65
    
    /// Raw representation of the public key.
    public let data: Data
    
    /// Whether this is a compressed key.
    public var isCompressed: Bool {
        return data.count == PublicKey.compressedSize && data[0] == 2 || data[0] == 3
    }
    
    /// Returns the compressed public key.
    public var compressedKey: PublicKey {
        if isCompressed {
            return self
        }
        let prefix: UInt8 = 0x02 | (data[64] & 0x01)
        return PublicKey(data: Data(_: [prefix]) + data[1 ..< 33])!
    }
    
    /// Creates a public key from a raw representation.
    /// - Parameter data: data
    public init?(data: Data) {
        guard PublicKey.isValid(data: data) else { return nil }
        self.data = data
    }
    
    
    public static func isValid(data: Data) -> Bool {
        switch data.first {
        case 2, 3:
            return data.count == PublicKey.compressedSize
        case 4, 6, 7:
            return data.count == PublicKey.uncompressedSize
        default:
            return false
        }
    }

    
    // MARK: - CustomStringConvertible
    public var description: String {
        return data.hexString
    }
    
    //MARK: - Hashable
    //https://stackoverflow.com/questions/55516776/how-can-i-update-this-hashable-hashvalue-to-conform-to-new-requirements
    public func hash(into hasher: inout Hasher) {
        hasher.combine(data)
    }
    
    public static func == (lhs: PublicKey, rhs: PublicKey) -> Bool {
        return lhs.data == rhs.data
    }
    
}
