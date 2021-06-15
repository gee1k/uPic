//
// Created by Bq Lin on 2021/5/19.
// Copyright (c) 2021 Bq. All rights reserved.
//

import Foundation
import ImageIO
import CoreServices

public class ImageIOEncoder: ImageEncoder, ImageEncoderSettings {
    public var firstFrameOnly: Bool = false
    
    public var outputUTI: CFString?
    public let supportedUTIs = CGImageDestinationCopyTypeIdentifiers() as! [CFString]
    let animationUTI: Set<CFString> = [kUTTypeGIF, kUTTypePNG]
    
    public init() {
        outputUTI = kUTTypePNG
        // print("supportedType: \(supportedUTIs)")
        // kUTTypeImage（抽象类）：kUTTypeJPEG、kUTTypePNG、kUTTypeGIF、kUTTypeTIFF、kUTTypePDF
    }
    
    public func encode(image: CommonImage) -> Data? {
        guard let outputUTI = outputUTI else { return nil }
        guard supportedUTIs.contains(outputUTI) else { return nil }
        
        guard image.coverImage != nil else { return nil }
        if firstFrameOnly || !image.hasAnimation || !allowAnimation(for: outputUTI) {
            return encode(image: image.coverImage!)
        }
        
        let data = NSMutableData()
        guard let destination = makeDestination(image: image, data: data as CFMutableData) else { return nil }
        for frame in image.frames {
            encode(frame: frame, destination: destination)
        }
        guard CGImageDestinationFinalize(destination) else { return nil }
        
        return (data.copy() as! Data)
    }
    
    /// 编码单帧图片
    public func encode(image: CGImage) -> Data? {
        guard let outputUTI = outputUTI else { return nil }
        
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data as CFMutableData, outputUTI, 1, nil) else { return nil }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        
        return (data.copy() as! Data)
    }
    
    func allowAnimation(for uti: CFString) -> Bool { animationUTI.contains(uti) }
    
    // 多帧
    func encode(frame: CommonImage.Frame, destination: CGImageDestination) {
        guard let outputUTI = outputUTI else { return }
        
        var info = [CFString: Any]()
        switch outputUTI {
            case kUTTypeGIF:
                if let duration = frame.duration {
                    info[kCGImagePropertyGIFDictionary] = [kCGImagePropertyGIFDelayTime: duration]
                }
            case kUTTypePNG:
                if let duration = frame.duration {
                    info[kCGImagePropertyPNGDictionary] = [kCGImagePropertyAPNGDelayTime: duration]
                }
            default: break
        }
        CGImageDestinationAddImage(destination, frame.image, info as CFDictionary)
    }
    
    func makeDestination(image: CommonImage, data: CFMutableData) -> CGImageDestination? {
        guard let outputUTI = outputUTI else { return nil }
        guard image.frames.count > 0 else { return nil }
        guard let destination = CGImageDestinationCreateWithData(data, outputUTI, image.hasAnimation ? image.frames.count : 1, nil) else { return nil }
        
        var info = [CFString: Any]()
        switch outputUTI {
            case kUTTypeGIF:
                info[kCGImagePropertyGIFDictionary] = [kCGImagePropertyGIFLoopCount: image.loopCount]
            case kUTTypePNG:
                info[kCGImagePropertyPNGDictionary] = [kCGImagePropertyAPNGLoopCount: image.loopCount]
            default: break
        }
        CGImageDestinationSetProperties(destination, info as CFDictionary)
        
        return destination
    }
}
