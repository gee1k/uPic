//
//  Data+Extension.swift
//  
//
//  Created by Svend on 2022/6/26.
//

import Foundation

internal extension Data {
    
    func toString(_ encoding: String.Encoding = .utf8) -> String? {
        return String(data: self, encoding: encoding)
    }
    
}
