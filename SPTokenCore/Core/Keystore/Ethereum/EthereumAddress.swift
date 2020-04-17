//
//  EthereumAddress.swift
//  SPTokenCore
//
//  Created by SPARK-Daniel on 2020/4/16.
//  Copyright © 2020 SPARK-Daniel. All rights reserved.
//

import Foundation

public typealias Result = String

public struct EthereumAddress: Address, Hashable {
   
    public static let size = 20
    
    /// Raw address bytes, length 20.
    public let data: Data
    
    
    /// EIP55 representation of the address.
    public var EIP55Result: Result {
        return EthereumChecksum(data: data).EIP55Address()
    }
    
    
    /// ETH address
    public var result: Result {
        return Hex.addPrefix(data.hexString)
    }
    
    public init?(data: Data) {
        guard EthereumAddress.isValid(data: data) else {
            return nil
        }
        self.data = data
    }
    
    public init?(hex: String) {
        guard let data = Data(hexString: hex) else { return nil }
        self.init(data: data)
    }
    
//MARK: - Private
    
    static func isValid(data: Data) -> Bool {
        return data.count == EthereumAddress.size
    }
    
    static func isValid(hex: String) -> Bool {
        guard let data = Data(hexString: hex) else { return false }
        return EthereumAddress.isValid(data: data)
    }
    
    
    //MARK: - CustomStringConvertible
    
    public var description: String {
        return self.EIP55Result
    }
    
    //MARK: - Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(data)
    }
    
    public static func == (lhs: EthereumAddress, rhs: EthereumAddress) -> Bool {
        return lhs.data == rhs.data
    }
    
    
}
