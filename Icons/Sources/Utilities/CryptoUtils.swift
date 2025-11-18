//
//  CryptoUtils.swift
//  Icons Free Version - Cryptographic Utilities
//
//  Created by MightyKartz on 2024/11/18.
//

import Foundation
import Crypto

struct CryptoUtils {

    // MARK: - Encryption

    static func encrypt(_ data: Data) throws -> Data {
        let key = deriveKey()
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined!
    }

    // MARK: - Decryption

    static func decrypt(_ encryptedData: Data) throws -> Data {
        let key = deriveKey()
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        return decryptedData
    }

    // MARK: - Key Derivation

    private static func deriveKey() -> SymmetricKey {
        // 使用应用程序标识符和设备信息生成固定密钥
        let appId = "com.iconsfree.app"
        let deviceId = getDeviceIdentifier()
        let combined = "\(appId)-\(deviceId)"

        let data = combined.data(using: .utf8)!
        let hash = SHA256.hash(data: data)
        return SymmetricKey(data: Data(hash))
    }

    // MARK: - Device Identifier

    private static func getDeviceIdentifier() -> String {
        // 获取设备唯一标识符
        let deviceId = UserDefaults.standard.string(forKey: "device_identifier")
        if let deviceId = deviceId {
            return deviceId
        }

        let newDeviceId = UUID().uuidString
        UserDefaults.standard.set(newDeviceId, forKey: "device_identifier")
        return newDeviceId
    }

    // MARK: - Validation

    static func isValidAPIKey(_ key: String, for provider: AIProvider) -> Bool {
        switch provider {
        case .openai:
            return key.hasPrefix("sk-") && key.count >= 20
        case .anthropic:
            return key.hasPrefix("sk-ant-") && key.count >= 30
        case .modelscope:
            return key.count >= 20
        case .stability:
            return key.count >= 20
        case .google:
            return key.count >= 20
        case .custom:
            return key.count >= 1
        }
    }
}