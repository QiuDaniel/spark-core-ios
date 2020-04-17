//
//  SPTokenCoreTests.swift
//  SPTokenCoreTests
//
//  Created by SPARK-Daniel on 2020/4/13.
//  Copyright © 2020 SPARK-Daniel. All rights reserved.
//

import XCTest
@testable import SPTokenCore
@testable import CryptoSwift

class SPTokenCoreTests: XCTestCase {

    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
       
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCrypto() throws {
        let crypto = Crypto(password: "testpassword", privateKey: "7a28b5ba57c53603b0b07b56bba752f7784bf506fa95edc395f5cf6c7514fe9d", iv: "6087dab2f9fdbbfaddc31a909735c1e6", salt: "ae3cd4e7013836a3df6bd7241b12db061dbe2c6785853cce422d148a624ce0bd", cacheDerivedKey: true)
        let string = crypto.toJSON()["mac"] as! String
        XCTAssertTrue(string == "517ead924a9d0dc3124507e3393d175ce3ff7c1e96529c6c555ce9e51205e9b2")
    }
    
    func testScrypt() throws {
        let crypto = Crypto(password: "testpassword", privateKey: "7a28b5ba57c53603b0b07b56bba752f7784bf506fa95edc395f5cf6c7514fe9d", iv: "83dbcc02d8ccb40e466191a123791e0e", cipher: .aes128ctr, kdf: .scrypt, salt: "ab0c7876052600dd703518d6fc3fe8984592145b591fc8fb5c6d43190334ba19", cacheDerivedKey: true)
        let string = crypto.toJSON()["mac"] as! String
        XCTAssertTrue(string == "2103ac29920d71da29f15d75b4a16dbe95cfd7ff8faea1056c33131d846e3097")
    }
    
    func testPBKDF2Length() {
      let password: Array<UInt8> = "testpassword".bytes
      let salt: Array<UInt8> = Array(hex: "ae3cd4e7013836a3df6bd7241b12db061dbe2c6785853cce422d148a624ce0bd")
      let value = try! PKCS5.PBKDF2(password: password, salt: salt, iterations: 262144, keyLength: 32, variant: .sha256).calculate()
      XCTAssertEqual(value.toHexString(), "f06d69cdc7da0faffb1008270bca38f5e31891a3a773950e6d0fea48a7188551")
    }
    
    func testETHAddress() {
        let privateKey = PrivateKey(data: Data(hexString: "7a28b5ba57c53603b0b07b56bba752f7784bf506fa95edc395f5cf6c7514fe9d")!)!
        let publicKey = privateKey.publicKey()
        let address = publicKey.ethereumAddress.result
        XCTAssertEqual(address, Hex.addPrefix("008aeeda4d805471df9b2a5b0f38a0c3bcba786b"))
    }
    
    func testKeystore() throws {
        let keystore = try! EthereumKeystore(password: "testpassword", privateKey: "7a28b5ba57c53603b0b07b56bba752f7784bf506fa95edc395f5cf6c7514fe9d")
        XCTAssertEqual(keystore.export(), "517ead924a9d0dc3124507e3393d175ce3ff7c1e96529c6c555ce9e51205e9b2")
//        XCTAssert(keystore.export().contains("008aeeda4d805471df9b2a5b0f38a0c3bcba786b"))
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }


    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
