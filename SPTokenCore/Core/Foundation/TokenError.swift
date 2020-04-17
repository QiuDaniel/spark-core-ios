//
//  TokenError.swift
//  SPTokenCore
//
//  Created by SPARK-Daniel on 2020/4/13.
//  Copyright © 2020 SPARK-Daniel. All rights reserved.
//

import Foundation

public protocol TokenError: Error {
    var message: String { get }
}

public extension TokenError where Self: RawRepresentable, Self.RawValue == String {
    var message: String {
        return rawValue
    }
}

public enum KeystoreError: String, TokenError {
  case invalid = "keystore_invalid"
  case cipherUnsupported = "cipher_unsupported"
  case kdfUnsupported = "kdf_unsupported"
  case prfUnsupported = "prf_unsupported"
  case kdfParamsInvalid = "kdf_params_invalid"
  case macUnmatch = "mac_unmatch"
  case privateKeyAddressUnmatch = "private_key_address_not_match"
  case containsInvalidPrivateKey = "keystore_contains_invalid_private_key"
}
