//
// Created by Bq Lin on 2021/5/18.
// Copyright (c) 2021 Bq. All rights reserved.
//

import Foundation
import ImageIO

public class ImageIODecoder: ImageDecoder, ImageDecoderSettings {
    // MARK: 配置
    public var firstFrameOnly: Bool = false
    public var ignoreOriginalImage: Bool = true
    
    public var maxWidth: Int? {
        set {
            _maxWidth = newValue
        }
        get {
            guard let value = _maxWidth else { return nil }
            return value > 0 ? value : nil
        }
    }
    
    public var maxHeight: Int? {
        set {
            _maxHeight = newValue
        }
        get {
            guard let value = _maxHeight else { return nil }
            return value > 0 ? value : nil
        }
    }
    
    private var _maxWidth: Int?
    private var _maxHeight: Int?
    
    public init() {
        contextInfo = ContextInfo()
        contextInfo.baseOptions = [
            // kCGImageSourceShouldCacheImmediately: true,
            // kCGImageSourceShouldCache: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
        ]
    }
    
    var contextInfo: ContextInfo!
    
    public func decode(data: Data) -> CommonImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let frameCount = CGImageSourceGetCount(source)
        guard frameCount > 0 else { return nil }
        
        if firstFrameOnly || frameCount == 1 {
            guard let frame = makeFrame(from: source, index: 0) else { return nil }
            return CommonImage(frame)
        }
        
        var loopCount = 0
        if let sourceInfo = CGImageSourceCopyProperties(source, nil) as? [CFString: Any] {
            if let gifInfo = sourceInfo[kCGImagePropertyGIFDictionary] as? [CFString: Any] {
                if let loop = gifInfo[kCGImagePropertyGIFLoopCount] as? Int {
                    loopCount = loop
                }
            }
        }
        
        var frames = [CommonImage.Frame]()
        for i in 0 ..< frameCount {
            guard let frame = makeFrame(from: source, index: i) else { continue }
            frames.append(frame)
        }
        return CommonImage(frames: frames, loopCount: loopCount)
    }
    
    func makeFrame(from source: CGImageSource, index: Int) -> CommonImage.Frame? {
        var frame = CommonImage.Frame()
        guard let sourceFrameInfo = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any] else { return nil }
        let width = sourceFrameInfo[kCGImagePropertyPixelWidth] as? Int ?? 0
        let height = sourceFrameInfo[kCGImagePropertyPixelHeight] as? Int ?? 0
        let exifOrientation = sourceFrameInfo[kCGImagePropertyOrientation] as? CGImagePropertyOrientation
        // uttype
        //_ = CGImageSourceGetType(source)
        
        frame.originalInfo[InfoKey.orientation] = exifOrientation ?? CGImagePropertyOrientation.up
        
        var image: CGImage!
        var originalImage: CGImage?
        
        func makeOriginalImage() -> CGImage? {
            CGImageSourceCreateImageAtIndex(source, index, options as CFDictionary)
        }
        
        // TODO: 处理图像方向
        var options = contextInfo.baseOptions
        let sizeLimited = CodecUtil.sizeLimited(src: (width, height), des: (maxWidth, maxHeight))
        if sizeLimited {
            let size = CodecUtil.convertedSize(src: (width, height), des: (maxWidth, maxHeight))
            let maxPixelSize = max(size.width, size.height)
            if maxPixelSize > 0 {
                options[kCGImageSourceThumbnailMaxPixelSize] = maxPixelSize
                options[kCGImageSourceCreateThumbnailFromImageAlways] = true
            }
            
            let limitedImage = CGImageSourceCreateThumbnailAtIndex(source, index, options as CFDictionary)
            
            image = limitedImage
            if !ignoreOriginalImage {
                originalImage = makeOriginalImage()
            }
        } else {
            image = makeOriginalImage()
            if !ignoreOriginalImage {
                originalImage = image
            }
        }
        
        if let gifInfo = sourceFrameInfo[kCGImagePropertyGIFDictionary] as? [CFString: Any] {
            if let duration = gifInfo[kCGImagePropertyGIFUnclampedDelayTime] as? Double {
                frame.duration = duration
            } else if let duration = gifInfo[kCGImagePropertyGIFDelayTime] as? Double {
                frame.duration = duration
            }
        }
        
        if let originalImage = originalImage {
            frame.originalInfo[CommonInfoKey.originalImage] = originalImage
        }
        frame.image = image
        frame.originalInfo[CommonInfoKey.width] = width
        frame.originalInfo[CommonInfoKey.height] = height
        
        return frame
    }
}

extension ImageIODecoder {
    struct ContextInfo {
        var baseOptions: [CFString: Any] = [:]
    }
    
    struct InfoKey {
        static let orientation = "orientation"
    }
}
