//
//  Array+Extension.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

extension Array {
    func elementForIndex(idx: Int?) -> Element? {
        guard let idx = idx else {
            return nil
        }
        guard idx <= (count - 1) else {
            return nil
        }
        return self[idx]
    }
}
