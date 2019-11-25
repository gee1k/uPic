//
//  PreviewItem.swift
//  uPic
//
//  Created by 侯猛 on 2019/10/22.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import Kingfisher
import SnapKit


class HistoryThumbnailItem: NSCollectionViewItem {
    
    private(set) var previewImageView: NSImageView!
    
    private var clickCopyButton: NSButton!
    
    private var fileNameScrollView: HistoryPreviewCustomScrollView!
    
    private(set) var fileName: NSTextField!
    /// 计时器
    private var _timer: DispatchSourceTimer?
    
    private var _scrollTimer: DispatchSourceTimer?
    
    var mouseStatusHandler: ((MouseStatus, NSPoint?, NSView) -> Void)?
    
    var copyUrl: (() -> Void)?
    
    private var lastFileNameScrollContentOffsetX: CGFloat = 0
    
    private var defaultFileNameScrollContentOffset: NSPoint?
    
    private var contentView: HistoryThumbnailContentView!
    
    override func loadView() {
        contentView = HistoryThumbnailContentView()
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviewCustom()
        addConstraintCustom()
        addBindSignal()
    }
    
    private func addSubviewCustom() {
        previewImageView = NSImageView()
        contentView.addSubview(previewImageView)
        clickCopyButton = NSButton()
        clickCopyButton.isTransparent = true
        contentView.addSubview(clickCopyButton)
        
        fileName = NSTextField()
        fileName.backgroundColor = NSColor.clear
        fileName.canDrawSubviewsIntoLayer = true
        fileName.cell = VerticalCenteringCell()
        fileName.alignment = .center
        fileName.isEditable = false
        fileName.appearance = NSAppearance(named: NSAppearance.Name.aqua)
        fileName.textColor = NSColor.white
        
        fileNameScrollView = HistoryPreviewCustomScrollView()
        fileNameScrollView.backgroundColor = NSColor.clear
        fileNameScrollView.documentView = fileName
        fileNameScrollView.drawsBackground = false
        fileNameScrollView.documentView?.scroll(.zero)
        contentView.addSubview(fileNameScrollView)
    }
    
    private func addConstraintCustom() {
        previewImageView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
        fileNameScrollView.snp.makeConstraints { (make) in
            make.left.right.equalTo(previewImageView)
            make.top.equalTo(previewImageView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        fileName.snp.makeConstraints { (make) in
            make.width.greaterThanOrEqualTo(fileNameScrollView.snp.width).priority(.high)
        }
        clickCopyButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func addBindSignal() {
        contentView.mouseStatusHandler = { [weak self] status, point, mouseView in
            guard let self = self else { return }
            switch status {
            case .entered:
                self.dispatchTimer(timeInterval: 0.5) { [weak self] in
                    guard let self = self else { return }
                    self.mouseStatusHandler?(.entered, point, mouseView)
                    self.cancelTimer()
                    self.beginScrollFileName()
                }
            case .exited:
                self.mouseStatusHandler?(.exited, point, mouseView)
                self.cancelTimer()
                self.cancelScrollTimer(true)
            case .moved:
                self.mouseStatusHandler?(.moved, point, mouseView)
            }
        }
        clickCopyButton.addTarget { [weak self] (_) in
            self?.copyUrl?()
        }
    }
    
    private func beginScrollFileName() {
        cancelScrollTimer(true)
        guard fileName.frame.width - (abs(fileName.frame.minX) * 2) > fileNameScrollView.frame.width else {
            return
        }
        if defaultFileNameScrollContentOffset == nil {
            defaultFileNameScrollContentOffset = fileNameScrollView.documentVisibleRect.origin
        }
        var bestRightDuration: CGFloat = 0
        let queue: DispatchQueue = DispatchQueue.global()
        let scrollTimer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 0), queue: queue)
        _scrollTimer = scrollTimer
        scrollTimer.schedule(deadline: .now(), repeating: fileNameScrollAnimationTime, leeway: DispatchTimeInterval.seconds(0))
        scrollTimer.setEventHandler(handler: { [weak self] in
            DispatchQueue.main.async(execute: {
                guard let self = self else { return }
                var x = self.fileNameScrollView.documentVisibleRect.origin.x + 1
                if (x + self.view.bounds.width) > self.fileNameScrollView.documentView?.frame.size.width ?? 0 {
                    x = (self.fileNameScrollView.documentView?.frame.size.width ?? 0) - self.fileNameScrollView.frame.size.width
                }
                self.fileNameScrollView.documentView?.scroll(NSPoint(x: x, y: 0))
                if self.fileNameScrollView.documentVisibleRect.origin.x == self.lastFileNameScrollContentOffsetX {
                    bestRightDuration += CGFloat(fileNameScrollAnimationTime)
                    if bestRightDuration >= 3 {
                        self.cancelScrollTimer(true)
                        self.beginScrollFileName()
                    }
                }
                self.lastFileNameScrollContentOffsetX = self.fileNameScrollView.documentVisibleRect.origin.x
            })
        })
        scrollTimer.resume()
        return
    }
    
    private func cancelTimer() {
        _timer?.cancel()
    }
    
    func cancelScrollTimer(_ resetLeft: Bool = false) {
        lastFileNameScrollContentOffsetX = 0
        _scrollTimer?.cancel()
        if resetLeft, let defaultFileNameScrollContentOffset = defaultFileNameScrollContentOffset {
            fileNameScrollView.documentView?.scroll(defaultFileNameScrollContentOffset)
        }
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
}

class VerticalCenteringCell: NSTextFieldCell {
    
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        var newRect: NSRect = super.drawingRect(forBounds: rect)
        let textSize: NSSize = cellSize(forBounds: rect)
        let heightDelta: CGFloat = newRect.size.height - textSize.height
        guard heightDelta > 0 else { return newRect }
        newRect.size.height = textSize.height
        newRect.origin.y += heightDelta * 0.5
        return newRect
    }
    
}
