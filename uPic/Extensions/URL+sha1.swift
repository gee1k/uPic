//
//  URL+sha1.swift
//  uPic
//
//  Created by tisfeng on 2024/6/9.
//  Copyright © 2024 Svend Jin. All rights reserved.
//

import Foundation
import CryptoSwift

extension URL {
    /// Get github file sha.
    func githubSHA() -> String? {
        do {
            let fileData = try Data(contentsOf: self)
            let header = "blob \(fileData.count)\0".data(using: .utf8)!
            var store = Data()
            store.append(header)
            store.append(fileData)
            let sha1 = store.sha1().toHexString()
            return sha1
        } catch {
            print("Error reading file: \(error)")
            return nil
        }
    }
}
