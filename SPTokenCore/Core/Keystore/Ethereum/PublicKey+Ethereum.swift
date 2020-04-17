//
//  PublicKey+Ethereum.swift
//  SPTokenCore
//
//  Created by SPARK-Daniel on 2020/4/16.
//  Copyright © 2020 SPARK-Daniel. All rights reserved.
//

import Foundation

extension PublicKey {
    public var ethereumAddress: EthereumAddress {
        let stringToEncrypt = data.hexString.substring(from: 2)
        let sha3Keccak: Data = Encryptor.Keccak256().encrypt(hex: stringToEncrypt)
        return EthereumAddress(data: sha3Keccak.suffix(EthereumAddress.size))!
    }
    
}
