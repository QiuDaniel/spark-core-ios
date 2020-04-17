//
//  Crypto+PublicKey.swift
//  SPTokenCore
//
//  Created by SPARK-Daniel on 2020/4/15.
//  Copyright © 2020 SPARK-Daniel. All rights reserved.
//

import Foundation
import TrezorCrypto

extension Crypto {
    /// Get uncompressed public key from private key
    /// - Parameter privateKeyData: private key raw data
    /// - Returns: Public Key Data
    
    // https://stackoverflow.com/questions/24110769/how-to-correctly-initialize-an-unsafepointer-in-swift
    // https://github.com/goldennetwork/GoldenKeystore/blob/master/HDKeyPair.swift
    static func unCompressedPublicKey(from privateKeyData: Data) -> Data {
        var pbKey = Data(repeating: 0, count: PublicKey.uncompressedSize)
        var secp256k1Data = secp256k1
        privateKeyData.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            guard let priBytes = ptr.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return }
            pbKey.withUnsafeMutableBytes { ( pbPtr:UnsafeMutableRawBufferPointer) in
                guard let pbBytes = pbPtr.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return }
                withUnsafePointer(to: &secp256k1Data) { (secPtr: UnsafePointer<ecdsa_curve>) in
                    ecdsa_get_public_key65(secPtr, priBytes, pbBytes)
                }
            }
        }
        return pbKey
    }
    
    /// Get compressed public key from private key
    /// - Parameter privateKeyData: private key raw data
    /// - Returns: Public Key Data
    
    static func compressedPublicKey(from privateKeyData: Data) -> Data {
        var pbKey = Data(repeating: 0, count: PublicKey.compressedSize)
        var secp256k1Data = secp256k1
        privateKeyData.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            guard let priBytes = ptr.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return }
            pbKey.withUnsafeMutableBytes { ( pbPtr:UnsafeMutableRawBufferPointer) in
                guard let pbBytes = pbPtr.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return }
                withUnsafePointer(to: &secp256k1Data) { (secPtr: UnsafePointer<ecdsa_curve>) in
                    ecdsa_get_public_key33(secPtr, priBytes, pbBytes)
                }
            }
        }
        return pbKey
    }
}
