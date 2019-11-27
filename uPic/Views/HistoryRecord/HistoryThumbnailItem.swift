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
    
    private var fileNameLeftRightSpacing: CGFloat = 5
    
    private(set) var previewImageView: NSImageView!
    
    private var clickCopyButton: NSButton!
    
    private(set) var fileNameView: NSView!
    
    private(set) var fileName: HistoryThumbnailLabel!
    /// 计时器
    private var _timer: DispatchSourceTimer?
    
    private var _scrollTimer: DispatchSourceTimer?
    
    var mouseStatusHandler: ((MouseStatus, NSPoint?, NSView) -> Void)?
    
    var copyUrl: (() -> Void)?
    
    private var fileNameLeft: Constraint?
    
    private var contentView: HistoryThumbnailContentView!
    
    private var whetherToScrollSequentially: Bool = true
    
    func updateTrackingAreas() {
        contentView.updateTrackingAreas()
    }
    
    override func loadView() {
        contentView = HistoryThumbnailContentView(frame: .zero, turnOnMonitoring: true)
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
        
        fileNameView = NSView()
        contentView.addSubview(fileNameView)
        
        fileName = HistoryThumbnailLabel()
        fileNameView.addSubview(fileName)
    }
    
    private func addConstraintCustom() {
        previewImageView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
        
        fileNameView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(fileNameLeftRightSpacing)
            make.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
        fileName.snp.makeConstraints { (make) in
            fileNameLeft = make.left.equalToSuperview().constraint
            make.bottom.equalToSuperview()
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(fileNameView)
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
                HistoryThumbnailTimer.shared.dispatchTimer(timeInterval: 0.5) { [weak self] timer in
                    guard let self = self else { return }
                    self.mouseStatusHandler?(.entered, point, mouseView)
                    timer.cancel()
                    self.beginScrollFileName()
                }
            case .exited:
                self.mouseStatusHandler?(.exited, point, mouseView)
                HistoryThumbnailTimer.shared.cancelAllTimer()
                self.fileNameLeft?.update(offset: 0)
            case .moved:
                self.mouseStatusHandler?(.moved, point, mouseView)
            }
        }
        clickCopyButton.addTarget { [weak self] (_) in
            self?.copyUrl?()
        }
    }
    
    private func beginScrollFileName() {
        guard fileName.frame.size.width != fileNameView.frame.size.width else { return }
        var stayTime: CGFloat = 0
        HistoryThumbnailTimer.shared.dispatchScrollTimer(timeInterval: HistoryRecordFileNameScrollSpeed) { [weak self] timer in
            guard let self = self else { return }
            let fileNameWidth = self.fileName.frame.size.width
            let fileNameMinX = self.fileName.frame.origin.x
            var newLeft: CGFloat = 0
            if self.whetherToScrollSequentially {
                newLeft = fileNameMinX - 1
            } else {
                newLeft = fileNameMinX + 1
            }
            let fileNameMaxX = newLeft + fileNameWidth
            if fileNameMaxX <= self.fileNameView.bounds.width, self.whetherToScrollSequentially == true {
                stayTime += CGFloat(HistoryRecordFileNameScrollSpeed)
                if stayTime >= HistoryRecordFileNameScrollWaitTimeGlobal {
                    stayTime = 0
                    self.whetherToScrollSequentially = false
                }
                return
            } else if fileNameMinX >= 0, self.whetherToScrollSequentially == false {
                stayTime += CGFloat(HistoryRecordFileNameScrollSpeed)
                if stayTime >= HistoryRecordFileNameScrollWaitTimeGlobal {
                    stayTime = 0
                    self.whetherToScrollSequentially = true
                }
                return
            }
            self.fileNameLeft?.update(offset: newLeft)
        }
        return
    }
}
