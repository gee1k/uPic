//
//  String+Extension.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/16.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import CommonCrypto
import CryptoSwift

extension String {
   
    func toBytes() -> Array<UInt8> {
        return self.bytes
    }

    func toMd5() -> String {
        return self.md5()
    }

    func toBase64() -> String {
        return self.bytes.toBase64()!
    }

    func toSha1() -> String {
        return self.sha1()
    }

    func toSha224() -> String {
        return self.sha224()
    }

    func toSha256() -> String {
        return self.sha256()
    }

    func toSha384() -> String {
        return self.sha384()
    }

    func toSha512() -> String {
        return self.sha512()
    }

    func calculateHMACByKey(key: String) -> Array<UInt8> {
        let hmac = try! HMAC(key: key.toBytes(), variant: .sha1).authenticate(self.toBytes())
        return hmac
    }
    
    func calculateHMAC256ByKey(key: Array<UInt8>) -> Array<UInt8> {
        let hmac = try! HMAC(key: key, variant: .sha256).authenticate(self.toBytes())
        return hmac
    }
    
    func calculateHMAC256ByKey(key: String) -> Array<UInt8> {
        let hmac = try! HMAC(key: key.toBytes(), variant: .sha256).authenticate(self.toBytes())
        return hmac
    }

}
