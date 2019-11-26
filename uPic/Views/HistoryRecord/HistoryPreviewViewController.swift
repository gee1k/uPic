//
//  PreImageViewController.swift
//  uPic
//
//  Created by 侯猛 on 2019/10/24.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import SnapKit

class HistoryPreviewViewController: NSViewController {

    var preImageView: NSImageView!
    
    private var trackingArea: NSTrackingArea?
    
    private var contentView: HistoryThumbnailContentView!
    
    private var widthConstraint: Constraint!
    
    private var heightConstraint: Constraint!
    
    override func loadView() {
        contentView = HistoryThumbnailContentView(frame: .zero, turnOnMonitoring: false)
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviewCustom()
        addConstraintCustom()
    }
    
    private func addSubviewCustom() {
        preImageView = NSImageView()
        contentView.addSubview(preImageView)
    }
    
    private func addConstraintCustom() {
        preImageView.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalToSuperview()
            widthConstraint = make.width.equalTo(0).constraint
            heightConstraint = make.height.equalTo(0).constraint
        }
    }
    
    func updatePreImage(url: String, size: NSSize) {
        
        let screenWidth = NSScreen.main?.frame.width ?? 0
        let screenMinX = Float((NSScreen.main?.frame.origin.x ?? 0))
        var mouseX = NSEvent.mouseLocation.x
        if screenMinX >= 0 {
            mouseX = mouseX - CGFloat(screenMinX)
        } else {
            mouseX = CGFloat(fabsf(screenMinX)) + mouseX
        }
        
        let leftVisibleArea = mouseX - 160
        let rightVisibleArea = screenWidth - (mouseX + 160)
        var newPreImageSize: NSSize = size
        
        if size.width > leftVisibleArea, size.width > rightVisibleArea {
            let newPreImageSizeWidth = leftVisibleArea > rightVisibleArea ? leftVisibleArea : rightVisibleArea
            let newPreImageSizeHeight = newPreImageSizeWidth / (size.width / size.height)
            newPreImageSize = NSSize(width: newPreImageSizeWidth, height: newPreImageSizeHeight)
        }
        widthConstraint.update(offset: newPreImageSize.width)
        heightConstraint.update(offset: newPreImageSize.height)
        
        preImageView.kf.indicatorType = .activity
        preImageView.kf.setImage(with: URL(string: url)!)
    }
}
