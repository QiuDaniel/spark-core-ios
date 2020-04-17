//
//  Address.swift
//  SPTokenCore
//
//  Created by SPARK-Daniel on 2020/4/16.
//  Copyright © 2020 SPARK-Daniel. All rights reserved.
//

import Foundation

protocol Address: CustomStringConvertible {
    
    /// Raw representation of the address.
    var data: Data { get }
    
    
    /// reates a address from a raw representation.
    /// - Parameter data: raw representation
    init?(data: Data)
    
    
    /// Creates an address with an hexadecimal string representation.
    /// - Parameter hex: hex string
    init?(hex: String)
}
