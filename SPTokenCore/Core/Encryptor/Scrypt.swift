//
//  Scrypt.swift
//  SPTokenCore
//
//  Created by SPARK-Daniel on 2020/4/14.
//  Copyright © 2020 SPARK-Daniel. All rights reserved.
//

import Foundation
import CryptoSwift
import CoreBitcoin.libscrypt

extension Encryptor {
    class Scrypt {
        private let password: String
        private let salt: String
        private let n: Int
        private let r: Int
        private let p: Int
        private let dklen = 32
        
        init(password: String, salt: String, n: Int, r: Int, p: Int) {
            self.password = password
            self.salt = salt
            self.n = n
            self.r = r
            self.p = p
        }
        
        func encrypt() -> String {
            
            let passwordBytes = password.data(using: .utf8)!.bytes
            let saltBytes = [UInt8](hex: salt)
            var data = Data(count: dklen)
            data.withUnsafeMutableBytes { (ptr: UnsafeMutableRawBufferPointer) in
                guard let bytes = ptr.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                    return
                }
                libscrypt_scrypt(passwordBytes, passwordBytes.count, saltBytes, saltBytes.count, UInt64(n), UInt32(r), UInt32(p), bytes, dklen)

            }
            return data.sp_toHexString()
//            let passwordBytes = Array(password.data(using: .ascii)!)
//            let saltBytes = Array(hex: salt)
//
//            if let deriver = try? CryptoSwift.Scrypt(password: passwordBytes, salt: saltBytes, dkLen: dklen, N: n, r: r, p: p) {
////                if let encrypted = try? scrypt.calculate() {
////                    return Data(_: encrypted).sp_toHexString()
////                }
//                let encrypted = try! deriver.calculate()
//                return Data(_: encrypted).sp_toHexString()
//            }
//
//            return ""
        }
    }
}
