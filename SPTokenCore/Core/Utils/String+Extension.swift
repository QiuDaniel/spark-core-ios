//
//  String+Extension.swift
//  SPTokenCore
//
//  Created by SPARK-Daniel on 2020/4/14.
//  Copyright © 2020 SPARK-Daniel. All rights reserved.
//

import Foundation

public extension String {
    
    func toHexString() -> String {
        return data(using: .utf8)!.sp_toHexString()
    }
    
    func substring(to: Int) -> String {
        return String(dropLast(count - to))
    }
    
    func substring(from: Int) -> String {
        return String(dropFirst(from))
    }
    
    func dataFromHexString() -> Data? {
        if Hex.hasHexPrefix(self) {
            return substring(from: 2).dataFromHexString()
        }
        
        let length = count
        if length % 2 == 1 {
            return ("0" + self).dataFromHexString()
        }
        
        if isEmpty {
            return Data()
        }
        
        if !Hex.isHex(self) {
            return nil
        }
        
        guard let chars = cString(using: .utf8) else { return nil }
        guard let data = NSMutableData(capacity: length / 2) else { return nil }
        var byteChars: [CChar] = [0, 0, 0]
        var wholeByte: CUnsignedLong = 0
        
        for i in stride(from: 0, to: length, by: 2) {
            byteChars[0] = chars[i]
            byteChars[1] = chars[i + 1]
            wholeByte = strtoul(byteChars, nil, 16)
            data.append(&wholeByte, length: 1)
        }
        
        return data as Data
    }
}
