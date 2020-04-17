//
//  Keystore.swift
//  SPTokenCore
//
//  Created by SPARK-Daniel on 2020/4/14.
//  Copyright © 2020 SPARK-Daniel. All rights reserved.
//

import Foundation

public protocol Keystore {
    var id: String { get }
    var version: Int { get }
    var crypto: Crypto { get }
    var address: String { get }
    
    func dump() -> String
    func toJSON() -> JSONObject
    func verify(_ password: String) -> Bool
}

protocol ExportableKeystore: Keystore {
    func export() -> String
}

protocol PrivateKeyCrypto {
    var crypto: Crypto { get }
    func decryptPrivateKey(password: String) -> String
}

public extension Keystore {
    
    static func generateKeystorId() -> String {
        return NSUUID().uuidString.lowercased()
    }
    
    func verify(_ password: String) -> Bool {
        let macFromPassword = crypto.mac(from: password)
        let mac = crypto.mac
        return macFromPassword.lowercased() == mac.lowercased()
    }
    
    func dump() -> String {
        let json = toJSON()
        return json.string
    }
    
    //FIXME: - test
    func toJSON() -> JSONObject {
        var json = standardJSON()
        json["test"] = "test"
        return json
    }
    
    func standardJSON() -> JSONObject {
        return [
            "id": id,
            "version": version,
            "crypto": crypto.toJSON(),
            "address": address
        ]
    }
}

extension ExportableKeystore {
    func export() -> String {
        let json = standardJSON()
        return json.string
    }
}

extension PrivateKeyCrypto {
    func decryptPrivateKey(password: String) -> String {
        return crypto.privateKey(password)
    }
}
