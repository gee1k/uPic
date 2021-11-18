//
// Created by Bq Lin on 2021/6/15.
// Copyright (c) 2021 Bq. All rights reserved.
//

import Foundation
import CoreServices

let UTIMap: [FileType: CFString] = [
    .tif: kUTTypeTIFF,
    .ico: kUTTypeICO,
    .bmp: kUTTypeBMP,
    .gif: kUTTypeGIF,
    .png: kUTTypePNG,
    .jpg: kUTTypeJPEG,
]

public extension FileType {
    var ext: String {
        MimeType.all.first { $0.type == self }!.ext
    }
    
    var UTI: CFString? {
        UTIMap[self]
    }
}

