//
//  PBKDF2.swift
//  SPTokenCore
//
//  Created by SPARK-Daniel on 2020/4/14.
//  Copyright © 2020 SPARK-Daniel. All rights reserved.
//

import Foundation
import CryptoSwift
import CoreBitcoin.libscrypt

extension Encryptor {
    class PBKDF2 {
        private let password: String
        private let salt: String
        private let iterations: Int
        private let keyLength: Int
        
        init(password: String, salt: String, iterations: Int, keyLength: Int = 32) {
            self.password = password
            self.salt = salt
            self.iterations = iterations
            self.keyLength = keyLength
        }
        
        
        /// Encrypt input string and return encrypted string in hex format.
        /// - Returns: encrypted hex string
        func encrypt() -> String {
            
            let saltBytes = [UInt8](hex: salt)
            let passwordBytes = password.data(using: .utf8)!.bytes
            var data = Data(count: keyLength)
            data.withUnsafeMutableBytes { (ptr: UnsafeMutableRawBufferPointer) in
                guard let bytes = ptr.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                    return
                }
                libscrypt_PBKDF2_SHA256(passwordBytes, passwordBytes.count, saltBytes, saltBytes.count, UInt64(iterations), bytes, keyLength)

            }
            return data.sp_toHexString()
            
//            let passwordBytes = Array(password.data(using: .ascii)!)
//            let saltBytes = Array(hex: salt)
//
//            // CryptoSwift method took a lot of time
//            if let pbkdf2 = try? PKCS5.PBKDF2(password: passwordBytes, salt: saltBytes, iterations: iterations, keyLength: keyLength)  {
//                if let encrypted = try? pbkdf2.calculate() {
//                    return Data(_ :encrypted).hexString
//                }
//            }
//            return ""
        }
    }
}
