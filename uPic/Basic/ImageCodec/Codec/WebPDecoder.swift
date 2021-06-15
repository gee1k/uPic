//
// Created by Bq Lin on 2021/5/17.
// Copyright (c) 2021 Bq. All rights reserved.
//

import CoreGraphics
import Foundation
import libwebp

public class WebPDecoder: ImageDecoder, ImageDecoderSettings {
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
    
    public init() {}
    
    // MARK:
    
    private var contextInfo: ContextInfo!
    
    public func decode(data: Data) -> CommonImage? {
        data.withUnsafeBytes { [weak self] (pointer: UnsafeRawBufferPointer) in
            guard let self = self else { return nil }
            
            let size = pointer.count
            let baseAddress = pointer.baseAddress!.assumingMemoryBound(to: UInt8.self)
            var data = WebPData(bytes: baseAddress, size: size)
            let demuxer = WebPDemux(&data)
            defer {
                WebPDemuxDelete(demuxer)
            }
            
            let flags = WebPDemuxGetI(demuxer, WEBP_FF_FORMAT_FLAGS)
            let hasAnimation = flags & ANIMATION_FLAG.rawValue != 0
            
            let colorSpace = self.makeColorSpace(demuxer: demuxer)
            let originalWidth = Int(WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_WIDTH))
            let originalHeight = Int(WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_HEIGHT))
            let frameCount = Int(WebPDemuxGetI(demuxer, WEBP_FF_FRAME_COUNT))
            let loopCount = Int(WebPDemuxGetI(demuxer, WEBP_FF_LOOP_COUNT))
            guard frameCount > 0, originalWidth > 0, originalHeight > 0 else { return nil }
            
            contextInfo = ContextInfo(colorSpace: colorSpace, originalWidth: originalWidth, originalHeight: originalHeight)
            
            // TODO:
            // let imageSize = self.convertedSize(CGSize(width: originalWidth, height: originalHeight))
            
            var iter = WebPIterator()
            defer {
                WebPDemuxReleaseIterator(&iter)
            }
            guard WebPDemuxGetFrame(demuxer, 1, &iter) != 0 else {
                return nil
            }
            
            // 首帧
            if !hasAnimation || firstFrameOnly {
                return makeCoverImage(webpData: iter.fragment)
            }
            
            // 多帧动画
            let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
            guard let blendCanvas = CGContext(data: nil, width: originalWidth, height: originalHeight, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo) else { return nil }
            var frames = [CommonImage.Frame]()
            repeat {
                guard let frame = makeFrameImage(blendCanvas: blendCanvas, iterator: iter) else { continue }
                frames.append(frame)
            } while WebPDemuxNextFrame(&iter) != 0
            guard frames.count == frameCount else {
                print("fail to decode some frame!")
                return nil
            }
            
            let sizeLimited = CodecUtil.sizeLimited(src: (originalWidth, originalHeight), des: (maxWidth, maxHeight))
            if sizeLimited {
                let size = CodecUtil.convertedSize(src: (originalWidth, originalHeight), des: (maxWidth, maxHeight))
                frames = frames.map { frame in
                    var frame = frame
                    if let resizeImage = frame.image.draw.makeImage(toSize: size) {
                        frame.image = resizeImage
                    }
                    return frame
                }
            }
            
            return CommonImage(frames: frames, loopCount: loopCount)
        }
    }
    
    private func makeColorSpace(demuxer: OpaquePointer!) -> CGColorSpace {
        var colorSpace: CGColorSpace!
        let flags = WebPDemuxGetI(demuxer, WEBP_FF_FORMAT_FLAGS)
        if flags & ICCP_FLAG.rawValue != 0 {
            var chunkIter = WebPChunkIterator()
            let result = WebPDemuxGetChunk(demuxer, "ICCP", 1, &chunkIter)
            if result != 0 {
                let profileData = Data(bytes: chunkIter.chunk.bytes, count: chunkIter.chunk.size)
                //colorSpace = CGColorSpace(iccProfileData: profileData as CFData)
                colorSpace = CGColorSpace(iccData: profileData as CFTypeRef)
                WebPDemuxReleaseChunkIterator(&chunkIter)
                // 排除RGB以外的颜色模型
                if colorSpace.model != .rgb {
                    colorSpace = nil
                }
            }
        }
        
        return colorSpace ?? CGColorSpaceCreateDeviceRGB()
    }
    
    private func makeCoverImage(webpData: WebPData) -> CommonImage? {
        var hasAlpha = false
        guard let originalImage = makeOriginalImage(webpData: webpData, hasAlpha: &hasAlpha) else { return nil }
        let width = originalImage.width
        let height = originalImage.height
        let sizeLimited = CodecUtil.sizeLimited(src: (width, height), des: (maxWidth, maxHeight))
        if sizeLimited {
            let size = CodecUtil.convertedSize(src: (width, height), des: (maxWidth, maxHeight))
            if let image = originalImage.draw.makeImage(toSize: size) {
                var frame = CommonImage.Frame()
                frame.originalInfo[CommonInfoKey.width] = width
                frame.originalInfo[CommonInfoKey.height] = height
                if !ignoreOriginalImage {
                    frame.originalInfo[CommonInfoKey.originalImage] = originalImage
                }
                frame.image = image
                return CommonImage(frame)
            }
        }
        
        return CommonImage(originalImage)
    }
    
    private func makeOriginalImage(webpData: WebPData, hasAlpha: inout Bool) -> CGImage? {
        var config = WebPDecoderConfig()
        guard WebPInitDecoderConfig(&config) != 0 else { return nil }
        
        guard WebPGetFeatures(webpData.bytes, webpData.size, &config.input) == VP8_STATUS_OK else { return nil }
        
        hasAlpha = config.input.has_alpha != 0
        var bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue
        bitmapInfo |= (hasAlpha ? CGImageAlphaInfo.premultipliedFirst.rawValue : CGImageAlphaInfo.noneSkipFirst.rawValue)
        config.output.colorspace = MODE_bgrA
        config.options.use_threads = 1
        // 这里做大小限制怕因offset影响，所以不在这里限制
        // config.options.use_scaling = 1
        // config.options.scaled_width = 100
        
        guard WebPDecode(webpData.bytes, webpData.size, &config) == VP8_STATUS_OK else { return nil }
        
        let provider = CGDataProvider(dataInfo: nil, data: config.output.u.RGBA.rgba, size: config.output.u.RGBA.size) { _, data, _ in
            data.deallocate()
        }
        guard provider != nil else { return nil }
        
        let w = Int(config.output.width)
        let h = Int(config.output.height)
        let bpc = 8
        let bpp = 32
        let bpr = Int(config.output.u.RGBA.stride)
        guard let image = CGImage(width: w, height: h, bitsPerComponent: bpc, bitsPerPixel: bpp, bytesPerRow: bpr, space: contextInfo.colorSpace, bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo), provider: provider!, decode: nil, shouldInterpolate: false, intent: .defaultIntent) else { return nil }
        return image
    }
    
    private func makeFrameImage(blendCanvas: CGContext, iterator iter: WebPIterator) -> CommonImage.Frame? {
        var frame = CommonImage.Frame()
        
        var duration = TimeInterval(iter.duration)
        if duration <= 10 {
            duration = 100
        }
        duration /= 1000
        frame.duration = duration
        
        var hasAlpha = false
        guard let originalImage = makeOriginalImage(webpData: iter.fragment, hasAlpha: &hasAlpha) else { return nil }
        if !ignoreOriginalImage {
            frame.originalInfo[CommonInfoKey.originalImage] = originalImage
        }
        
        let frameWidth = Int(iter.width)
        let frameHeight = Int(iter.height)
        let offsetX = Int(iter.x_offset)
        let offsetY = contextInfo.originalHeight - frameHeight - Int(iter.y_offset)
        let frameRect = CGRect(x: offsetX, y: offsetY, width: frameWidth, height: frameHeight)
        frame.originalInfo[CommonInfoKey.width] = frameWidth
        frame.originalInfo[CommonInfoKey.height] = frameHeight
        
        let shouldBlend = iter.blend_method == WEBP_MUX_BLEND
        if !shouldBlend {
            blendCanvas.clear(frameRect)
        }
        blendCanvas.draw(originalImage, in: frameRect)
        guard let image = blendCanvas.makeImage() else { return nil }
        frame.image = image
        
        defer {
            if iter.dispose_method == WEBP_MUX_DISPOSE_BACKGROUND {
                blendCanvas.clear(frameRect)
            }
        }
        
        return frame
    }
}

extension WebPDecoder {
    struct ContextInfo {
        let colorSpace: CGColorSpace
        let originalWidth: Int
        let originalHeight: Int
        
        var size: CGSize {
            CGSize(width: originalWidth, height: originalHeight)
        }
        
        var bounds: CGRect {
            CGRect(origin: .zero, size: size)
        }
    }
}
