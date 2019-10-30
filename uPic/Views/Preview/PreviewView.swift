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
    static let collectionViewItem = NSUserInterfaceItemIdentifier(NSStringFromClass(PreviewItem.self))
}

class PreviewView: NSView {
    
    private(set) var preViewImageView: NSImageView!
    
    private var mainCollectionView: NSCollectionView!
    
    private var mainScrollView: NSScrollView!
    
    private var clearHistoryButton: NSButton!
    
    private var prePopover: NSPopover!
    
    private var preImageViewController: PreImageViewController!
    
    private var currentPreItemModel: PreviewModel!

    private var currentCell: PreviewItem?
    
    
    var superMenu: NSMenu!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initializeView()
        
    }
    
    func initializeView() {
        
        let flowLayout = PreviewFlowLayout()
        flowLayout.edgeInset = NSEdgeInsets(top: 10.0, left: 5, bottom: 10.0, right: 5)
        flowLayout.columnCount = 3
        flowLayout.lineSpacing = 4
        flowLayout.columnSpacing = 4
        
        mainCollectionView = NSCollectionView(frame: bounds)
        mainCollectionView.backgroundColors = [NSColor.clear]
        mainCollectionView.collectionViewLayout = flowLayout
        mainCollectionView.register(PreviewItem.self, forItemWithIdentifier: .collectionViewItem)
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        
        mainScrollView = NSScrollView()
        mainScrollView.backgroundColor = NSColor.clear
        mainScrollView.documentView = mainCollectionView
        addSubview(mainScrollView)
        mainScrollView.contentView.postsBoundsChangedNotifications = true
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(boundsDidChangeNotification(notification:)), name: NSView.boundsDidChangeNotification, object: mainScrollView.contentView)
        
        clearHistoryButton = NSButton(image: NSImage(named: "cleanButton")!, target: self, action: #selector(clearHistory))
//        clearHistoryButton.isHighlighted = true
        clearHistoryButton.bezelStyle = .smallSquare
//        clearHistoryButton.isTransparent = true
        addSubview(clearHistoryButton)
        
        preImageViewController = PreImageViewController(nibName: "PreImageViewController", bundle: nil)
        prePopover = NSPopover()
        prePopover.contentViewController = preImageViewController
        prePopover.animates = false
        prePopover.delegate = self
    }
    
    @objc
    private func clearHistory() {
        print("清理")
        ConfigManager.shared.clearHistoryList_New()
        mainCollectionView.reloadData()
    }
    
    override func layout() {
        super.layout()
        mainScrollView.frame = NSRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        mainCollectionView.frame = mainScrollView.bounds
        clearHistoryButton.frame = NSRect(x: bounds.size.width - 49, y: 0, width: 44, height: 44)
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
        if let item = currentCell, item.fileName.isHidden == false {
            item.fileName.isHidden = true
        }
    }
    
}

extension PreviewView: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let historyList = ConfigManager.shared.getHistoryList_New()
        let model = historyList[indexPath.item]
        let item = collectionView.makeItem(withIdentifier: .collectionViewItem, for: indexPath) as! PreviewItem
        let urlString = model.url
        //        let url = URL(string: urlString.urlEncoded())!
        item.fileName.stringValue = model.fileName != nil ? model.fileName! : "我没名字"
        if model.isImage == true {
            if let imageData = model.thumbnailData {
                item.previewImageView.image = NSImage(data: imageData)
            }
        } else {
            item.previewImageView.image = NSImage(named: "fileImage")
        }
        item.copyUrl = { [weak self] in
            self?.copyUrl(urlString)
            self?.superMenu.cancelTracking()
        }
        item.mouseStatusHandler = { [weak self] status in
            self?.currentCell = item
            guard let self = self else {
                return
            }
            guard model.isImage == true else {
                return
            }
            switch status {
            case .entered:
                self.currentPreItemModel = model
                self.prePopover.show(relativeTo: item.view.bounds, of: item.view, preferredEdge: NSRectEdge.maxX)
                self.preImageViewController.updatePreImage(url: urlString.urlEncoded())
            case .exited:
                self.prePopover.performClose(item.view)
            case .moved:
                self.prePopover.performClose(item.view)
            }
        }
        return item
    }
    
}

extension PreviewView: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        let historyList = ConfigManager.shared.getHistoryList_New()
        clearHistoryButton.isHidden = historyList.count == 0
        return historyList.count
    }
}

extension PreviewView: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let historyList = ConfigManager.shared.getHistoryList_New()
        let model = historyList[indexPath.item]
        let itemSize = NSSize(width: model.thumbnailWidth,
                              height: model.thumbnailHeight)
        
        return itemSize
    }
}

extension PreviewView: PreviewFlowLayoutDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, itemWidth: CGFloat, heightForItemAt indexPath: IndexPath) -> CGFloat {
        let historyList = ConfigManager.shared.getHistoryList_New()
        let model = historyList[indexPath.item]
        return model.thumbnailHeight
    }
}

extension PreviewView: NSPopoverDelegate {
    func popoverDidShow(_ notification: Notification) {
        let size = NSSize(width: currentPreItemModel.previewWidth, height: currentPreItemModel.previewHeight)
        prePopover.contentSize = size
    }
    
}
