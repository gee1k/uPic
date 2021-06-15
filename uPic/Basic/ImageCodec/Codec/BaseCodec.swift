//
// Created by Bq Lin on 2021/5/18.
// Copyright (c) 2021 Bq. All rights reserved.
//

import Foundation
import CoreGraphics

// MARK: Decoder

public protocol ImageDecoder {
    func decode(data: Data) -> CommonImage?
}

public protocol ImageDecoderSettings {
    /// 只解码第一帧
    var firstFrameOnly: Bool { get set }
    /// 不存储原图，仅当原图大小超过maxWidth、maxHeight大小时有效
    var ignoreOriginalImage: Bool { get set }
    /// 限制最大宽度
    var maxWidth: Int? { get set }
    /// 限制最大高度
    var maxHeight: Int? { get set }
}

// MARK: Encoder

public protocol ImageEncoder {
    func encode(image: CommonImage) -> Data?
    func encode(image: CGImage) -> Data?
}

public protocol ImageEncoderSettings {
    /// 只编码第一帧
    var firstFrameOnly: Bool { get set }
}
