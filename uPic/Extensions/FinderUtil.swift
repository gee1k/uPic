//
//  FinderUtil.swift
//  uPic
//
//  Created by Svend Jin on 2020/3/7.
//  Copyright © 2020 Svend Jin. All rights reserved.
//

import Foundation

class FinderUtil {
    private static var groupName: String {
        let infoDic = Bundle.main.infoDictionary!
        return "\(infoDic["TeamIdentifierPrefix"]!)com.svend.uPic"
    }
    static func removeIcon() {
        let defaults = UserDefaults.init(suiteName: groupName)
        defaults?.removeObject(forKey: "uPic_FinderExtensionIcon")
        defaults?.synchronize()
    }
    
    static func getIcon() -> Int {
        let defaults = UserDefaults.init(suiteName: groupName)
        guard let icon = defaults?.value(forKey: "uPic_FinderExtensionIcon") else {
            return 1
        }
        return icon as! Int
    }
    
    static func setIcon(_ value: Int) {
        let defaults = UserDefaults.init(suiteName: groupName)
        defaults?.set(value, forKey: "uPic_FinderExtensionIcon")
        defaults?.synchronize()
    }
}
