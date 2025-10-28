//
//  String+Crypto.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/28.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import CommonCrypto
import CryptoSwift

internal extension String {
    
    func calculateHMACByKey(key: Array<UInt8>) -> Array<UInt8> {
        let hmac = try! HMAC(key: key, variant: .sha1).authenticate(self.bytes)
        return hmac
    }
   
    func calculateHMACByKey(key: String) -> Array<UInt8> {
        return calculateHMACByKey(key: key.bytes)
    }
    
    func calculateHMAC256ByKey(key: Array<UInt8>) -> Array<UInt8> {
        let hmac = try! HMAC(key: key, variant: .sha2(.sha256)).authenticate(self.bytes)
        return hmac
    }
    
    func calculateHMAC256ByKey(key: String) -> Array<UInt8> {
        return calculateHMAC256ByKey(key: key.bytes)
    }

}
