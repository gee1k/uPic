//
// Created by Bq Lin on 2021/5/17.
// Copyright (c) 2021 Bq. All rights reserved.
//

import Foundation
import CoreGraphics
import Accelerate
import libwebp

public class WebPEncoder: ImageEncoder, ImageEncoderSettings {
    public var firstFrameOnly: Bool = false
    
    public init() {}
    
    public func encode(image: CommonImage) -> Data? {
        if firstFrameOnly || image.frames.count == 1 {
            return encode(image: image.coverImage!)
        } else {
            guard let mux = WebPMuxNew() else { return nil }
            defer {
                WebPMuxDelete(mux)
            }
            
            for (_, frame) in image.frames.enumerated() {
                guard let imageData = encode(image: frame.image) else { continue }
                
                let duration = Int(frame.duration! * 1000)
                var frameInfo = WebPMuxFrameInfo()
                frameInfo.bitstream = WebPData(bytes: (imageData as NSData).bytes.assumingMemoryBound(to: UInt8.self), size: imageData.count)
                frameInfo.duration = Int32(duration)
                frameInfo.id = WEBP_CHUNK_ANMF
                frameInfo.dispose_method = WEBP_MUX_DISPOSE_BACKGROUND
                frameInfo.blend_method = WEBP_MUX_NO_BLEND
                guard WebPMuxPushFrame(mux, &frameInfo, 0) == WEBP_MUX_OK else { return nil }
            }
            
            var params = WebPMuxAnimParams()
            params.bgcolor = 0
            params.loop_count = Int32(image.loopCount)
            guard WebPMuxSetAnimationParams(mux, &params) == WEBP_MUX_OK else { return nil }
            
            var outputData = WebPData()
            guard WebPMuxAssemble(mux, &outputData) == WEBP_MUX_OK else { return nil }
            defer {
                WebPDataClear(&outputData)
            }
            
            return Data(bytes: outputData.bytes, count: outputData.size)
        }
    }
    
    public func encode(image: CGImage) -> Data? {
        let width = image.width
        let height = image.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let alphaInfo = image.alphaInfo
        let hasAlpha: Bool = {
            switch alphaInfo {
                case .none, .noneSkipFirst, .noneSkipLast:
                    return false
                default:
                    return true
            }
        }()
        
        var srcFormat = vImage_CGImageFormat()
        srcFormat.bitsPerComponent = UInt32(image.bitsPerComponent)
        srcFormat.bitsPerPixel = UInt32(image.bitsPerPixel)
        srcFormat.colorSpace = Unmanaged.passUnretained(image.colorSpace!)
        srcFormat.bitmapInfo = image.bitmapInfo
        
        let desBitmapInfo = hasAlpha ? CGImageAlphaInfo.last.rawValue : CGImageAlphaInfo.none.rawValue
        var desFormat = vImage_CGImageFormat()
        desFormat.bitsPerComponent = 8
        desFormat.bitsPerPixel = hasAlpha ? 32 : 24
        desFormat.colorSpace = Unmanaged.passUnretained(colorSpace)
        desFormat.bitmapInfo = CGBitmapInfo(rawValue: desBitmapInfo)
        
        var error: vImage_Error = 0
        let convertor = vImageConverter_CreateWithCGImageFormat(&srcFormat, &desFormat, nil, vImage_Flags(kvImagePrintDiagnosticsToConsole), &error).takeRetainedValue()
        
        var src = vImage_Buffer()
        error = vImageBuffer_InitWithCGImage(&src, &srcFormat, nil, image, 0)
        guard error == 0 else { return nil }
        defer {
            src.data.deallocate()
        }
        
        var des = vImage_Buffer()
        error = vImageBuffer_Init(&des, vImagePixelCount(height), vImagePixelCount(width), desFormat.bitsPerPixel, 0)
        guard error == 0 else { return nil }
        defer {
            des.data.deallocate()
        }
        
        error = vImageConvert_AnyToAny(convertor, &src, &des, nil, 0)
        guard error == 0 else { return nil }
        
        let rgbaRaw = des.data
        let rgba = rgbaRaw?.assumingMemoryBound(to: UInt8.self)
        let bpr = des.rowBytes
        
        var config = WebPConfig()
        var picture = WebPPicture()
        var writer = WebPMemoryWriter()
        
        guard WebPConfigPreset(&config, WEBP_PRESET_DEFAULT, 100) != 0, WebPPictureInit(&picture) != 0 else { return nil }
        
        config.thread_level = 1
        
        picture.use_argb = 0
        picture.width = Int32(width)
        picture.height = Int32(height)
        picture.writer = WebPMemoryWrite
        picture.custom_ptr = withUnsafeMutablePointer(to: &writer) { UnsafeMutableRawPointer($0) }
        WebPMemoryWriterInit(&writer)
        defer {
            WebPMemoryWriterClear(&writer)
        }
        
        var result: Int32 = 0
        if hasAlpha {
            result = WebPPictureImportRGBA(&picture, rgba, Int32(bpr))
        } else {
            result = WebPPictureImportRGB(&picture, rgba, Int32(bpr))
        }
        guard result != 0 else { return nil }
        result = WebPEncode(&config, &picture)
        WebPPictureFree(&picture)
        
        if result != 0 {
            return Data(bytes: writer.mem, count: writer.size)
        }
        
        return nil
    }
}
