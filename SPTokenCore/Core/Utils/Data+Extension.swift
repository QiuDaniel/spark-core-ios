//
//  Data+Extension.swift
//  SPTokenCore
//
//  Created by SPARK-Daniel on 2020/4/13.
//  Copyright © 2020 SPARK-Daniel. All rights reserved.
//

import Foundation
import CryptoSwift

extension Data {
    
    public var hexString: String {
        return map({ String(format: "%02x", $0) }).joined()
    }
    
    init?(hexString: String) {
        var string: String
        if Hex.hasHexPrefix(hexString) {
            string = hexString.substring(from: 2)
        } else {
            string = hexString
        }
        
        guard let stringData = string.data(using: .ascii, allowLossyConversion: true) else {
            return nil
        }
        
        self.init(capacity: string.count / 2)
        
        let stringBytes = Array(stringData)
        for i in stride(from: 0, to: stringBytes.count, by: 2) {
            guard let high = Data.value(of: stringBytes[i]) else {
                return nil
            }
            
            if i < stringBytes.count - 1, let low = Data.value(of: stringBytes[i + 1]) {
                append((high << 4) | low)
            } else {
                append(high)
            }
        }
    }
    
    mutating public func clear() {
        resetBytes(in: 0 ..< count)
    }
    
    public func sp_toHexString() -> String {
        return toHexString() // From CryptoSwift
    }
    
    // https://stackoverflow.com/questions/55378409/swift-5-0-withunsafebytes-is-deprecated-use-withunsafebytesr
    public static func random(of length: Int) -> Data {
        var data = Data(count: length)
        data.withUnsafeMutableBytes { (ptr: UnsafeMutableRawBufferPointer) in
            guard let bytes = ptr.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                return
            }
            _ = SecRandomCopyBytes(kSecRandomDefault, length, bytes)
        }
        return data
    }
    
    //MARK: - Private
    
   /// Converts an ASCII byte to a hex value
   /// - Parameter nibble: ASCII byte
   /// - Returns: hex value
   private static func value(of nibble: UInt8) -> UInt8? {
       guard let letter = String(bytes: [nibble], encoding: .ascii) else { return nil }
       return UInt8(letter, radix: 16)
   }
    

}
