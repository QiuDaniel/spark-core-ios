//
//  EthereumChecksum.swift
//  SPTokenCore
//
//  Created by SPARK-Daniel on 2020/4/16.
//  Copyright © 2020 SPARK-Daniel. All rights reserved.
//

import Foundation

struct EthereumChecksum {
    
    private let data: Data
    private let address: Result
    
    var isChecksumValid: Bool {
        return address == EIP55Address()
    }
    
    
    init(data: Data) {
        self.data = data
        address = data.hexString
    }
    
    func EIP55Address() -> String {
        let address = Hex.removePrefix(self.address.lowercased())
        let hash: String = Encryptor.Keccak256().encrypt(hex: address.toHexString())
        
        let checksum = address.enumerated().map { (index, char) in
            let hashValue = hash.substring(from: index).substring(to: 1)
            if Int(hashValue, radix: 16)! >= 8 {
                return String(char).uppercased()
            }
            return String(char)
        }.joined()
        return Hex.addPrefix(checksum)
    }
    
}
