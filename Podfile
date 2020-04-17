platform :ios, "10.0"

target "SPTokenCore" do
  use_frameworks!

  pod 'CryptoSwift'
  pod 'BigInt'
  pod 'GRKOpenSSLFramework'
  pod "CoreBitcoin", git: "https://github.com/consenlabs/token-core-ios-dep.git"
  pod 'secp256k1.swift'
  pod 'TrezorCrypto'
  pod 'SwiftLint'
  pod 'MBProgressHUD'

  target "SPTokenCoreTests" do
    inherit! :search_paths
  end
end
