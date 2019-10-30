//
//  PreviewItem.swift
//  uPic
//
//  Created by 侯猛 on 2019/10/22.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import Kingfisher

enum MouseStatus {
    case entered
    case exited
    case moved
}


class PreviewItem: NSCollectionViewItem {
    

    @IBOutlet weak var previewImageView: NSImageView!
    @IBOutlet weak var clickCopyButton: NSButton!
    @IBOutlet weak var fileName: NSTextField!
    /// 计时器
    private var _timer: DispatchSourceTimer?
    
    private var trackingArea: NSTrackingArea?
    
    var mouseStatusHandler: ((MouseStatus) -> Void)?
    
    var copyUrl: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fileName.wantsLayer = true
        fileName.layer?.backgroundColor = NSColor(white: 0, alpha: 0.6).cgColor
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        previewImageView.frame = view.bounds
        clickCopyButton.frame = view.bounds
        fileName.frame = view.bounds
        if trackingArea != nil {
            view.removeTrackingArea(trackingArea!)
        }
        trackingArea = NSTrackingArea(rect: view.bounds, options:
            [.mouseEnteredAndExited,
             .activeInKeyWindow], owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea!)
    }
    
    override func mouseEntered(with event: NSEvent) {
        fileName.isHidden = false
        dispatchTimer(timeInterval: 0.3) { [weak self] in
            self?.mouseStatusHandler?(.entered)
            self?.cancelTimer()
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        fileName.isHidden = true
        mouseStatusHandler?(.exited)
        cancelTimer()
    }
    
    private func cancelTimer() {
        _timer?.cancel()
    }
    
    private func dispatchTimer(timeInterval: TimeInterval, handler:@escaping ()->()) {
        cancelTimer()
        let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        _timer = timer
        timer.schedule(wallDeadline: .now() + timeInterval, repeating: timeInterval)
        timer.setEventHandler(handler: {
            DispatchQueue.main.async {
                handler()
            }
            
        })
        timer.resume()
    }
    
    @IBAction func clickCopy(_ sender: Any) {
        copyUrl?()
    }
    
}
