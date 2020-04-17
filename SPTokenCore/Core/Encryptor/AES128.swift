//
//  AES128.swift
//  SPTokenCore
//
//  Created by SPARK-Daniel on 2020/4/14.
//  Copyright © 2020 SPARK-Daniel. All rights reserved.
//

import Foundation
import CryptoSwift

extension Encryptor {
    class AES128 {
        enum Mode {
            case ctr
            case cbc
        }
        
        private let key: String
        private let iv: String
        private let mode: Mode
        private let padding: Padding
        
        private var aes: AES? {
            let keyBytes = [UInt8].init(hex: key)
            let ivBytes = [UInt8].init(hex: iv)
            return try? AES(key: keyBytes, blockMode: blockMode(iv: ivBytes) , padding: self.padding)
        }
        
        init(key: String, iv: String, mode: Mode = .ctr, padding: Padding = .noPadding) {
            self.key = key
            self.iv = iv
            self.mode = mode
            self.padding = padding
        }
        
        //MARK: - Public Method
        
        func encrypt(string: String) -> String {
            return encrypt(hex: string.toHexString())
        }
        
        /// Encrypt input hex string and return encrypted string in hex format
        /// - Parameter hex: input hex string
        /// - Returns: encrypted string
        func encrypt(hex: String) -> String {
            guard let aes = aes else {
                return ""
            }
            
            let inputBytes = [UInt8].init(hex: hex)
            let encrypted = try! aes.encrypt(inputBytes)
            return Data(encrypted).sp_toHexString()
        }
        
        
        /// Decrypt input hex string and return decrypted string in hex format
        /// - Parameter hex: input hex string
        /// - Returns: decrypted string
        func decrypt(hex: String) -> String {
            guard let aes = aes else {
                return ""
            }
            let inputBytes = [UInt8].init(hex: hex)
            let decrypted = try! aes.decrypt(inputBytes)
            return Data(decrypted).sp_toHexString()
        }
        
        //MARK: - Private Method
        
        private func blockMode(iv: [UInt8]) -> BlockMode {
            switch mode {
            case .cbc:
                return CBC(iv: iv)
            case .ctr:
                return CTR(iv: iv)
            }
        }
    }
}
