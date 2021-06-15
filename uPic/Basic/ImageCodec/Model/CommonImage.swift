//
// Created by Bq Lin on 2021/5/16.
// Copyright (c) 2021 Bq. All rights reserved.
//

import CoreGraphics
import Foundation

public class CommonImage {
    var loopCount: Int = 0
    var frames = [Frame]()
    
    var coverImage: CGImage? {
        frames.first?.image
    }
    
    var hasAnimation: Bool {
        frames.count > 1 && totalDuration != nil
    }
    
    var totalDuration: TimeInterval? {
        let duration: TimeInterval = frames.reduce(0) { (result, frame: Frame) in
            result + (frame.duration ?? 0)
        }
        return duration == 0 ? nil : duration
    }
    
    init(_ image: CGImage) {
        var frame = Frame(image: image)
        frame.originalInfo[CommonInfoKey.width] = image.width
        frame.originalInfo[CommonInfoKey.height] = image.height
        frames = [frame]
    }
    
    init(_ frame: Frame) {
        frames = [frame]
    }
    
    init(frames: [Frame], loopCount: Int) {
        self.frames = frames
        self.loopCount = loopCount
    }
}

extension CommonImage {
    struct Frame {
        var image: CGImage!
        var duration: TimeInterval?
        var originalInfo: [String: Any] = [:]
    }
}

struct CommonInfoKey {
    static let width = "width" // Int
    static let height: String = "height" // Int
    static let originalImage = "originalImage" // CGImage
}

public extension CommonImage {
    var originalWidth: Int { frames.first?.originalInfo[CommonInfoKey.width] as! Int? ?? 0 }
    var originalHeight: Int { frames.first?.originalInfo[CommonInfoKey.height] as! Int? ?? 0 }
}
