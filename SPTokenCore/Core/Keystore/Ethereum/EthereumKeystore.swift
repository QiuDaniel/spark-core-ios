//
//  EthereumKeystore.swift
//  SPTokenCore
//
//  Created by SPARK-Daniel on 2020/4/16.
//  Copyright © 2020 SPARK-Daniel. All rights reserved.
//

import Foundation

struct EthereumKeystore: ExportableKeystore, PrivateKeyCrypto {
    
    let id: String
    
    /// Key version, must be 3.
    let version: Int = 3
    
    var address: String
    let crypto: Crypto
    
    /// Create an EthereumKeystore instance
    /// - Parameters
    ///   - password: password
    ///   - privateKey: privateKey hex string
    ///   - id: id
    /// - Throws: Error
    init(password: String, privateKey: String? = nil, id: String? = nil) throws {
        
        var priKey: PrivateKey
        if let privateKey = privateKey  {
            if privateKey.isEmpty {
                priKey = PrivateKey()
            } else {
                priKey = PrivateKey(data: Data(hexString: privateKey)!)!
            }
        } else {
            priKey = PrivateKey()
        }
        let tmpPrivateKey =  priKey.description
        address = priKey.publicKey().ethereumAddress.result
        crypto = Crypto(password: password, privateKey: tmpPrivateKey, kdf: .scrypt)
        self.id = id ?? EthereumKeystore.generateKeystorId()
    }
}
