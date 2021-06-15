//
// Created by Bq Lin on 2021/5/19.
// Copyright (c) 2021 Bq. All rights reserved.
//

import Foundation

public class CommonImageCodec: ImageDecoderSettings, ImageEncoderSettings {
    public var firstFrameOnly: Bool = false
    public var ignoreOriginalImage: Bool = true
    public var maxWidth: Int?
    public var maxHeight: Int?
    public init() {}
}

public extension CommonImageCodec {
    /// 目前支持 .jpg, .png, .gif, .tif, .bmp, .ico, .webp 格式相互转换
    func convert(data: Data, toType: FileType) -> Data? {
        guard let mine = Swime.mimeType(data: data) else { return nil }
        let fromType = mine.type
        
        guard let decoder = makeDecoder(type: fromType) else { return nil }
        guard let image = decoder.decode(data: data) else { return nil }
        let encodeForType = fromType != toType
        let encodeForFirstFrameOnly = firstFrameOnly && image.hasAnimation
        let encodeForMaxWidth: Bool = {
            var shouldEncode = false
            if let maxWidth = maxWidth {
                shouldEncode = image.originalWidth > maxWidth
            }
            return shouldEncode
        }()
        let encodeForMaxHeight: Bool = {
            var shouldEncode = false
            if let maxHeight = maxHeight {
                shouldEncode = image.originalHeight > maxHeight
            }
            return shouldEncode
        }()
        if !encodeForType, !encodeForFirstFrameOnly, !encodeForMaxWidth, !encodeForMaxHeight {
            debugPrint("无需转换，原样输出")
            return data
        }
        
        guard let encoder = makeEncoder(type: toType) else { return nil }
        return encoder.encode(image: image)
    }
}

extension CommonImageCodec {
    func usingWebp(type: FileType) -> Bool {
        type == .webp
    }
    
    func usingImageIO(type: FileType) -> Bool {
        switch type {
            case .jpg, .png, .gif, .tif, .bmp, .ico:
                return true
            default:
                return false
        }
    }
    
    func makeDecoder(type: FileType) -> ImageDecoder? {
        var decoder: (ImageDecoder & ImageDecoderSettings)!
        if false {
        } else if usingWebp(type: type) {
            let _coder = WebPDecoder()
            decoder = _coder
        } else if usingImageIO(type: type) {
            let _coder = ImageIODecoder()
            decoder = _coder
        }
        guard decoder != nil else { return nil }
        
        decoder.firstFrameOnly = firstFrameOnly
        decoder.ignoreOriginalImage = ignoreOriginalImage
        decoder.maxHeight = maxHeight
        decoder.maxWidth = maxWidth
        return decoder
    }
    
    func makeEncoder(type: FileType) -> ImageEncoder? {
        var encoder: (ImageEncoder & ImageEncoderSettings)!
        if false {
        } else if usingWebp(type: type) {
            let _coder = WebPEncoder()
            encoder = _coder
        } else if usingImageIO(type: type) {
            let _coder = ImageIOEncoder()
            _coder.outputUTI = type.UTI
            encoder = _coder
        }
        guard encoder != nil else { return nil }
        
        encoder.firstFrameOnly = firstFrameOnly
        return encoder
    }
}
