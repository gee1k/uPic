//
//  String+Crypto.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/28.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import CommonCrypto
import CryptoSwift
import Foundation

extension String {
    func calculateHMACByKey(key: [UInt8]) -> [UInt8] {
        let hmac = try! HMAC(key: key, variant: .sha1).authenticate(bytes)
        return hmac
    }

    func calculateHMACByKey(key: String) -> [UInt8] {
        return calculateHMACByKey(key: key.bytes)
    }

    func calculateHMAC256ByKey(key: [UInt8]) -> [UInt8] {
        let hmac = try! HMAC(key: key, variant: .sha2(.sha256)).authenticate(bytes)
        return hmac
    }

    func calculateHMAC256ByKey(key: String) -> [UInt8] {
        return calculateHMAC256ByKey(key: key.bytes)
    }
}
