//
//  Kdfparams.swift
//  SPTokenCore
//
//  Created by SPARK-Daniel on 2020/4/13.
//  Copyright © 2020 SPARK-Daniel. All rights reserved.
//

import Foundation
import CryptoSwift

protocol Kdfparams {
    init(json: JSONObject) throws
    func toJSON() -> JSONObject
    func derivedKey(for password: String) -> String
}

/**
 Web3 Secret Storage Definition
 https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition
*/

public class Crypto {
    enum Cipher: String {
        case aes128ctr = "aes-128-ctr" // AES-128-CTR is now the minimal requirement
        case aes128cbc = "aes-128-cbc" // Version 1 fixed algorithm
    }
    
    enum Kdf: String {
        case scrypt, pbkdf2
    }
    
    let cipher: Cipher
    let cipherparams: Cipherparams
    let ciphertext: String
    let kdf: Kdf
    let kdfparams: Kdfparams // KDF-dependent static and dynamic parameters to the KDF function
    let mac: String // SHA3 (keccak-256) of the concatenations of the second-leftmost 16 bytes of the derived key together with the full ciphertext
    
    public var cachedDerivedKey = CachedDerivedKey(hashedPassword: "", derivedKey: "")
    
    
    /// Generate Web3 Secret Storage Definition Crypto instance
    /// - Parameters:
    ///   - password: Password to encrypt private key
    ///   - privateKey: Private Key hex string
    ///   - iv: iv, default is Random
    ///   - cipher: AES128 mode, default is ase-128-ctr
    ///   - kdf: Hash mode, default is PKBDF2
    ///   - salt: Salt hex string
    ///   - cacheDerivedKey: Specify whether the crypto should cache derived key to avoid calling KDF function multiple times. If true, the caller can fetch derived key with `cachedDerivedKey(with password:)`,and should explictly call `clearDerivedKey()` afterwards.
    
    init(password: String, privateKey: String, iv: String? = nil, cipher: Cipher = .aes128ctr, kdf: Kdf = .pbkdf2, salt: String? = nil, cacheDerivedKey: Bool = false) {
        self.cipher = cipher
        cipherparams = Cipherparams(iv: iv)
        self.kdf = kdf
        switch kdf {
        case .pbkdf2:
            kdfparams = PBKDF2Kdfparams(salt: salt)
        default:
            kdfparams = ScryptKdfparams(salt: salt)
        }
        
        let derivedKey = kdfparams.derivedKey(for: password)
        if cacheDerivedKey {
            cachedDerivedKey.cache(password: password, derivedKey: derivedKey)
        }
        
        ciphertext = Encryptor.AES128(key: derivedKey.substring(to: 32), iv: cipherparams.iv, mode: Crypto.aesMode(cipher: cipher)).encrypt(hex: privateKey)
        
        let maxHex = derivedKey.substring(from: 32) + ciphertext
        mac = Encryptor.Keccak256().encrypt(hex: maxHex)
    }
    
    init(json: JSONObject) throws {
        guard let ciphertext = json["ciphertext"] as? String,
            let cipherparamsJson = json["cipherparams"] as? JSONObject,
            let kdfparamsJson = json["kdfparams"] as? JSONObject,
            let mac = json["mac"] as? String,
            let cipherStr = json["cipher"] as? String,
            let kdfStr = json["kdf"] as? String
        else { throw KeystoreError.invalid }
        
        guard let cipher = Cipher(rawValue: cipherStr.lowercased()) else { throw KeystoreError.cipherUnsupported }
        
        guard let kdf = Kdf(rawValue: kdfStr.lowercased()) else { throw KeystoreError.kdfUnsupported }
        
        let kdfparamsClass: Kdfparams.Type = kdf == .scrypt ? ScryptKdfparams.self : PBKDF2Kdfparams.self
        self.cipher = cipher
        self.ciphertext = ciphertext
        cipherparams = Cipherparams(json: cipherparamsJson)
        self.kdf = kdf
        kdfparams = try kdfparamsClass.init(json: kdfparamsJson)
        self.mac = mac
    }
    
    func toJSON() -> JSONObject {
        return [
            "cipher": cipher.rawValue,
            "ciphertext": ciphertext,
            "cipherparams": cipherparams.toJSON(),
            "kdf": kdf.rawValue,
            "kdfparams": kdfparams.toJSON(),
            "mac": mac
        ]
    }
}

//MARK: - Cache derivedKey

public extension Crypto {
    struct CachedDerivedKey {
        var hashedPassword: String
        var derivedKey: String
        
        mutating func cache(password: String, derivedKey: String) {
            hashedPassword = hash(password: password)
            self.derivedKey = derivedKey
        }
        
        mutating func clear() {
            hashedPassword = ""
            derivedKey = ""
        }
        
        func fetch(password: String) -> String? {
            if hash(password: password) == hashedPassword {
                return derivedKey
            }
            return nil
        }
        
        private func hash(password: String) -> String {
            return password.sha256().sha256()
        }
    }
}

// MARK: - Public
extension Crypto {
    
    func derivedKey(with password: String) -> String {
        if let cached = cachedDerivedKey.fetch(password: password) {
            return cached
        }
        return kdfparams.derivedKey(for: password)
    }
    
    func cachedDerivedKey(with password: String) -> String {
        if let cached = cachedDerivedKey.fetch(password: password) {
            return cached
        }
        
        let key = derivedKey(with: password)
        cachedDerivedKey.cache(password: password, derivedKey: key)
        return key
    }
    
    func clearDerivedKey() {
        cachedDerivedKey.clear()
    }
    
    
    /// Create encryptor with key and nonce
    /// - Parameters:
    ///   - key: key
    ///   - nonce: nonce
    ///   - AESMode: AESMode, default is aes-128-ctr
    /// - Returns: AES encryptor
    func encryptor(form key: String, nonce: String, AESMode: Encryptor.AES128.Mode? = nil) -> Encryptor.AES128 {
        let mode = AESMode ?? Crypto.aesMode(cipher: .aes128ctr)
        return Encryptor.AES128(key: key, iv: nonce, mode: mode)
    }
}

extension Crypto {
    
    func privateKey(_ password: String) -> String {
        let cipherKey = derivedKey(with: password).substring(to: 32)
        return Encryptor.AES128(key: cipherKey, iv: cipherparams.iv, mode: Crypto.aesMode(cipher: cipher)).decrypt(hex: ciphertext)
    }
    
    func mac(from password: String) -> String {
        return mac(forDerivedKey: derivedKey(with: password))
    }
    
    func mac(forDerivedKey derivedKey: String) -> String {
        return mac(forDerivedKey: derivedKey, cipherText: ciphertext)
    }
    
    func mac(forDerivedKey derivedKey: String, cipherText: String) -> String {
        let cipherKey = derivedKey.substring(from: 32)
        let maxHex = cipherKey + cipherText
        return Encryptor.Keccak256().encrypt(hex: maxHex)
    }
    
    static func aesMode(cipher: Cipher) -> Encryptor.AES128.Mode {
        switch cipher {
        case .aes128cbc:
            return .cbc
        case .aes128ctr:
            return .ctr
        }
    }
}

// MARK: KDF
extension Crypto {
    struct Cipherparams {
        let iv: String // 128-bit initialisation vector for the cipher.
        
        init(iv: String?) {
            self.iv = iv ?? Data.random(of: 16).sp_toHexString()
        }
        
        init(json: JSONObject) {
            iv = (json["iv"] as? String) ?? ""
        }
        
        func toJSON() -> JSONObject {
            return ["iv": iv]
        }
    }
    
    // https://en.wikipedia.org/wiki/PBKDF2
    
    struct PBKDF2Kdfparams: Kdfparams {
        let c: Int // number of iterations
        let dklen: Int // length for the derived key. Must be >= 32
        let prf: String // Must be hmac-sha256 (may be extended in the future)
        let salt: String // salt passed to PBKDF
        
        public static var defaultN = 262144
               
       init(salt: String?) {
           dklen = 32
           c = PBKDF2Kdfparams.defaultN
           prf = "hmac-sha256"
           self.salt = salt ?? Data.random(of: 32).sp_toHexString()
       }
        
        init(json: JSONObject) throws {
            guard let c = json["c"] as? Int, let dklen = json["dklen"] as? Int, let prf = json["prf"] as? String, let salt = json["salt"] as? String else {
                throw KeystoreError.kdfParamsInvalid
            }
            
            if c <= 0 {
                throw KeystoreError.kdfParamsInvalid
            }
            
            self.c = c
            
            if dklen < 32 {
                throw KeystoreError.kdfParamsInvalid
            }
            
            self.dklen = dklen
            
            if prf.lowercased() != "hmac-sha256" {
                throw KeystoreError.prfUnsupported
            }
            
            self.prf = prf.lowercased()
            
            if salt.isEmpty {
                throw KeystoreError.kdfParamsInvalid
            }
            
            self.salt = salt
        }
        
        func toJSON() -> JSONObject {
            return [
                "c": c,
                "dklen": dklen,
                "prf": prf,
                "salt": salt
            ]
        }
        
        func derivedKey(for password: String) -> String {
            return Encryptor.PBKDF2(password: password, salt: salt, iterations: c, keyLength: dklen).encrypt()
        }
    }
    
    public struct ScryptKdfparams: Kdfparams {
        let dklen: Int // Intended output length in octets of the derived key; a positive integer satisfying dkLen ≤ (2^32− 1) * hLen.
        let n: Int // CPU/memory cost parameter
        let r: Int // The blocksize parameter, which fine-tunes sequential memory read size and performance. 8 is commonly used.
        let p: Int
        let salt: String
        
        public static var defaultN = 262144
        
        init(salt: String?) {
            dklen = 32
            n = ScryptKdfparams.defaultN
            r = 8
            p = 1
            self.salt = salt ?? Data.random(of: 32).sp_toHexString()
        }
        
        init(json: JSONObject) throws {
            guard let dklen = json["dklen"] as? Int, let n = json["n"] as? Int, let r = json["r"] as? Int, let p = json["p"] as? Int, let salt = json["salt"] as? String else {
                throw KeystoreError.kdfParamsInvalid
            }
            
            if dklen != 32 || n <= 0 || r <= 0 || p <= 0 || salt.isEmpty {
                throw KeystoreError.kdfParamsInvalid
            }
            
            self.dklen = dklen
            self.n = n
            self.r = r
            self.p = p
            self.salt = salt
        }
        
        func toJSON() -> JSONObject {
            return [
                "dklen": dklen,
                "n": n,
                "r": r,
                "p": p,
                "salt": salt
            ]
        }
        
        func derivedKey(for password: String) -> String {
            return Encryptor.Scrypt(password: password, salt: salt, n: n, r: r, p: p).encrypt()
        }
    }
}
