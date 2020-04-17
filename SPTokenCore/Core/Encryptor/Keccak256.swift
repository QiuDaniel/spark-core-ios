//
//  Keccak256.swift
//  SPTokenCore
//
//  Created by SPARK-Daniel on 2020/4/14.
//  Copyright © 2020 SPARK-Daniel. All rights reserved.
//

import Foundation
import CryptoSwift

extension Encryptor {
    class Keccak256 {
        init() {}
        
        func encrypt(hex: String) -> String {
            return encrypt(hex: hex).sp_toHexString()
        }
        
        func encrypt(hex: String) -> Data {
            return encrypt(data: Data(hexString: hex)!)
        }
        
        private func encrypt(data: Data) -> Data {
            return Data(SHA3(variant: .keccak256).calculate(for: data.bytes))
        }
    }
}
