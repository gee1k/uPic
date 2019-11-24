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
    
    private(set) var fileName: NSTextField!
    /// 计时器
    private var _timer: DispatchSourceTimer?
    
    var mouseStatusHandler: ((MouseStatus, NSPoint?, NSView) -> Void)?
    
    var copyUrl: (() -> Void)?
    
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
        fileName.canDrawSubviewsIntoLayer = true
        fileName.cell = VerticalCenteringCell()
        fileName.alignment = .center
        fileName.isEditable = false
        fileName.appearance = NSAppearance(named: NSAppearance.Name.aqua)
        fileName.textColor = NSColor.white
        contentView.addSubview(fileName)
    }
    
    private func addConstraintCustom() {
        previewImageView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
        fileName.snp.makeConstraints { (make) in
            make.left.right.equalTo(previewImageView)
            make.top.equalTo(previewImageView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        clickCopyButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func addBindSignal() {
        contentView.mouseStatusHandler = { [weak self] status, point, mouseView in
            switch status {
            case .entered:
                self?.dispatchTimer(timeInterval: 0.5) { [weak self] in
                    self?.mouseStatusHandler?(.entered, point, mouseView)
                    self?.cancelTimer()
                }
            case .exited:
                self?.mouseStatusHandler?(.exited, point, mouseView)
                self?.cancelTimer()
            case .moved:
                self?.mouseStatusHandler?(.moved, point, mouseView)
            }
        }
        clickCopyButton.addTarget { [weak self] (_) in
            self?.copyUrl?()
        }
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
