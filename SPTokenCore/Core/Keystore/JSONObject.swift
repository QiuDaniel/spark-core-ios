//
//  JSONObject.swift
//  SPTokenCore
//
//  Created by SPARK-Daniel on 2020/4/13.
//  Copyright © 2020 SPARK-Daniel. All rights reserved.
//

import Foundation

public typealias JSONObject = [String: Any]

extension JSONObject {
    
    var string: String {
        return toString()
    }
    
    private func toString() -> String {
        let data = try! JSONSerialization.data(withJSONObject: self, options: [])
        return String(data: data, encoding: .utf8)!
    }
}
