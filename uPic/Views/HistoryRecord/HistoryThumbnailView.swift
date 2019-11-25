//
//  HistoryViewController.swift
//  uPic
//
//  Created by 侯猛 on 2019/10/22.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import Alamofire
import Kingfisher


extension NSUserInterfaceItemIdentifier {
    static let collectionViewItem = NSUserInterfaceItemIdentifier(NSStringFromClass(HistoryThumbnailItem.self))
}

class HistoryThumbnailView: NSView {
    
    private(set) var preViewImageView: NSImageView!
    
    private var mainCollectionView: NSCollectionView!
    
    private var mainScrollView: NSScrollView!
    
    private var clearHistoryButton: NSButton!
    
    private var prePopover: NSPopover!
    
    private var preImageViewController: HistoryPreviewViewController!
    
    private var currentPreItemModel: HistoryThumbnailModel!

    private var currentCell: HistoryThumbnailItem?
    
    var superMenu: NSMenu!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initializeView()
    }
    
    private func initializeView() {
        
        let flowLayout = HistoryThumbnailFlowLayout()
        flowLayout.edgeInset = NSEdgeInsets(top: historyRecordLeftRightInsetGlobal, left: 5, bottom: 50.0, right: historyRecordLeftRightInsetGlobal)
        flowLayout.columnCount = previewLineNumberGlobal
        flowLayout.lineSpacing = previewLineSpacingGlobal
        
        mainCollectionView = NSCollectionView(frame: bounds)
        
        mainCollectionView.backgroundColors = [NSColor.clear]
        mainCollectionView.collectionViewLayout = flowLayout
        mainCollectionView.register(HistoryThumbnailItem.self, forItemWithIdentifier: .collectionViewItem)
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        
        mainScrollView = NSScrollView(frame: bounds)
        mainScrollView.backgroundColor = NSColor.clear
        mainScrollView.documentView = mainCollectionView
        addSubview(mainScrollView)
        mainScrollView.contentView.postsBoundsChangedNotifications = true
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(boundsDidChangeNotification(notification:)), name: NSView.boundsDidChangeNotification, object: mainScrollView.contentView)
        
        clearHistoryButton = NSButton(image: NSImage(named: "cleanButton")!, target: self, action: #selector(clearHistory))
        clearHistoryButton.appearance = NSAppearance(named: NSAppearance.Name.aqua)
        clearHistoryButton.bezelStyle = .smallSquare
        clearHistoryButton.toolTip = "Clear upload history".localized
        clearHistoryButton.isTransparent = true
        addSubview(clearHistoryButton)
        
        preImageViewController = HistoryPreviewViewController()
        prePopover = NSPopover()
        prePopover.contentViewController = preImageViewController
        prePopover.animates = false
        
    }
    
    @objc
    private func clearHistory() {
        ConfigManager.shared.clearHistoryList_New()
        mainCollectionView.reloadData()
    }
    
    override func layout() {
        super.layout()
        mainScrollView.frame = NSRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        clearHistoryButton.frame = NSRect(x: bounds.size.width - 60, y: 0, width: 44, height: 44)
    }
    
    
    // copy history url
    @objc func copyUrl(_ url: String) {
        let outputUrl = (NSApplication.shared.delegate as? AppDelegate)?.copyUrls(urls: [url])
        NotificationExt.shared.postCopySuccessfulNotice(outputUrl)
    }
    
    @objc // 滑动
    private func boundsDidChangeNotification(notification: NSNotification) {
        if prePopover.isShown {
            self.prePopover.performClose(self)
        }
    }
    
}

extension HistoryThumbnailView: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let historyList = ConfigManager.shared.getHistoryList_New()
        let model = historyList[indexPath.item]
        let item = collectionView.makeItem(withIdentifier: .collectionViewItem, for: indexPath) as! HistoryThumbnailItem
        let urlString = model.url
        item.fileName.stringValue = URL(string: urlString.urlEncoded())!.lastPathComponent
        if model.isImage == true {
            if let imageData = model.thumbnailData {
                item.previewImageView.image = NSImage(data: imageData)
            }
        } else {
            item.previewImageView.image = NSImage(named: "fileImage")
        }
        item.copyUrl = { [weak self] in
            self?.copyUrl(urlString.urlEncoded())
            self?.superMenu.cancelTracking()
        }
        item.mouseStatusHandler = { [weak self] status, point, mouseView in
            self?.currentCell = item
            guard let self = self else {
                return
            }
            guard model.isImage == true else {
                if self.prePopover.isShown { self.prePopover.performClose(item.view) }
                return
            }
            switch status {
            case .entered:
                self.currentPreItemModel = model
                guard mouseView.window != nil else {
                    return
                }
                self.prePopover.show(relativeTo: mouseView.bounds, of: mouseView, preferredEdge: NSRectEdge.maxX)
                self.preImageViewController.updatePreImage(url: urlString.urlEncoded(), size: NSSize(width: model.previewWidth, height: model.previewHeight))
            case .exited:
                if self.prePopover.isShown {
                    self.prePopover.performClose(item.view)
                }
                break
            case .moved:
                break
            }
        }
        return item
    }
    
}

extension HistoryThumbnailView: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        let historyList = ConfigManager.shared.getHistoryList_New()
        clearHistoryButton.isHidden = historyList.count == 0
        return historyList.count
    }
}

extension HistoryThumbnailView: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let historyList = ConfigManager.shared.getHistoryList_New()
        let model = historyList[indexPath.item]
        return model.thumbnailSize
    }
}

extension HistoryThumbnailView: HistoryThumbnailFlowLayoutDelegate {
    func collectionView(_ collectionView: NSCollectionView, itemWidth: CGFloat, heightForItemAt indexPath: IndexPath) -> CGFloat {
        let historyList = ConfigManager.shared.getHistoryList_New()
        let model = historyList[indexPath.item]
        return model.thumbnailHeight
    }
}

extension HistoryThumbnailView: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        mainCollectionView.reloadData()
    }
}
