//
//  PrivateKey.swift
//  SPTokenCore
//
//  Created by SPARK-Daniel on 2020/4/15.
//  Copyright © 2020 SPARK-Daniel. All rights reserved.
//

import Foundation

public final class PrivateKey: Hashable, CustomStringConvertible {
    
    /// Private key size in bytes.
    public static let size = 32
    
    public private(set) var data: Data
    
    
    deinit {
        clear()
    }
    
    /// Creates a new private key
    public init() {
        let privateAttri: [String: Any] = [kSecAttrIsExtractable as String: true]
        let params: [String: Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeEC,
                                     kSecAttrKeySizeInBits as String: PrivateKey.size * 8,
                                     kSecPrivateKeyAttrs as String: privateAttri]
        guard let privateKey = SecKeyCreateRandomKey(params as CFDictionary, nil) else { fatalError("Failed to generate key pair") }
        guard var keyRaw = SecKeyCopyExternalRepresentation(privateKey, nil) as Data? else {
            fatalError("Failed to extract new private key")
        }
        
        defer {
            keyRaw.clear()
        }
        
        data = Data(keyRaw.suffix(PrivateKey.size))
        
    }
    
    /// Creates a private key from a raw representation.
    /// - Parameter data: data
    public init?(data: Data) {
        guard PrivateKey.isValid(data: data) else {
            return nil
        }
        self.data = Data(data)
    }
    
    //MARK: - Public
    
    /// Validates that raw data is a valid private key.
    /// - Parameter data: data
    /// - Returns: ture or false
    public static func isValid(data: Data) -> Bool {
        if data.count != PrivateKey.size { // Check length
            return false
        }
        return data.contains(where: { $0 != 0 })
    }
    
    /// Returns the public key associated with this pirvate key.
    /// - Parameter compressed: whether to generate a compressed public key
    /// - Returns: public key
    func publicKey(compressed: Bool = false) -> PublicKey {
        let pkData: Data
        if compressed {
            pkData = Crypto.compressedPublicKey(from: data)
        } else {
            pkData = Crypto.unCompressedPublicKey(from: data)
        }
        return PublicKey(data: pkData)!
    }
    
    
    //MARK: - Private
    
    private func clear() {
        data.clear()
    }
    
    //MARK: - CustomStringConvertible
    
    public var description: String {
        return data.hexString
    }
    
    // MARK: - Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(data)
    }
    
    public static func == (lhs: PrivateKey, rhs: PrivateKey) -> Bool {
        return lhs.data == rhs.data
    }
    
}
