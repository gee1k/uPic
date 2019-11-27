//
//  PreviewFlowLayout.swift
//  uPic
//
//  Created by 侯猛 on 2019/10/23.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

public let CollectionViewWaterfallElementKindSectionHeader = "CollectionViewWaterfallElementKindSectionHeader"
public let CollectionViewWaterfallElementKindSectionFooter = "CollectionViewWaterfallElementKindSectionFooter"

@objc public protocol HistoryThumbnailFlowLayoutDelegate: NSCollectionViewDelegate {
    @objc func collectionView(_ collectionView: NSCollectionView, layout: NSCollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: NSCollectionViewLayout, heightForHeaderInSection section: Int) -> Float
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: NSCollectionViewLayout, heightForFooterInSection section: Int) -> Float
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: NSCollectionViewLayout, insetForSection section: Int) -> NSEdgeInsets
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: NSCollectionViewLayout, insetForHeaderInSection section: Int) -> NSEdgeInsets
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: NSCollectionViewLayout, insetForFooterInSection section: Int) -> NSEdgeInsets
    
    @objc optional func collectionView(_ collectionView: NSCollectionView, layout: NSCollectionViewLayout, minimumInteritemSpacingForSection section: Int) -> Float
    
}

public class HistoryThumbnailFlowLayout: NSCollectionViewLayout {
    
    // MARK: - Private constants
    /// How many items to be union into a single rectangle
    private let unionSize = 20
    
    // MARK: - Public Properties
    public var columnCount: Int = 2 {
        didSet {
            invalidateIfNotEqual(oldValue, newValue: columnCount)
        }
    }
    public var minimumColumnSpacing: Float = 10.0 {
        didSet {
            invalidateIfNotEqual(oldValue, newValue: minimumColumnSpacing)
        }
    }
    public var minimumInteritemSpacing: Float = 10.0 {
        didSet {
            invalidateIfNotEqual(oldValue, newValue: minimumInteritemSpacing)
        }
    }
    public var headerHeight: Float = 0.0 {
        didSet {
            invalidateIfNotEqual(oldValue, newValue: headerHeight)
        }
    }
    public var footerHeight: Float = 0.0 {
        didSet {
            invalidateIfNotEqual(oldValue, newValue: footerHeight)
        }
    }
    public var headerInset: NSEdgeInsets = NSEdgeInsetsZero {
        didSet {
            invalidateIfNotEqual_NSEdgeInsets(oldValue, newValue: headerInset)
        }
    }
    public var footerInset:NSEdgeInsets = NSEdgeInsetsZero {
        didSet {
            invalidateIfNotEqual_NSEdgeInsets(oldValue, newValue: footerInset)
        }
    }
    public var sectionInset:NSEdgeInsets = NSEdgeInsetsZero {
        didSet {
            invalidateIfNotEqual_NSEdgeInsets(oldValue, newValue: sectionInset)
        }
    }
    
    public override var collectionViewContentSize: CGSize {
        let numberOfSections = collectionView?.numberOfSections
        if numberOfSections == 0 {
            return CGSize.zero
        }
        
        var contentSize = collectionView?.bounds.size
        contentSize?.height = CGFloat(columnHeights[0])
        
        return contentSize!
    }
    
    // MARK: - Private Properties
    private weak var delegate: HistoryThumbnailFlowLayoutDelegate?  {
        get {
            return collectionView?.delegate as? HistoryThumbnailFlowLayoutDelegate
        }
    }
    private var columnHeights = [Float]()
    private var sectionItemAttributes = [[NSCollectionViewLayoutAttributes]]()
    private var allItemAttributes = [NSCollectionViewLayoutAttributes]()
    private var headersAttribute = [Int: NSCollectionViewLayoutAttributes]()
    private var footersAttribute = [Int: NSCollectionViewLayoutAttributes]()
    private var unionRects = [CGRect]()
    
    // MARK: - NSCollectionViewLayout Methods
    public override func prepare() {
        super.prepare()
        
        guard let numberOfSections = collectionView?.numberOfSections else {
            return
        }
        
        guard let delegate = delegate else {
            assertionFailure("NSCollectionView's delegate should conform to WaterfallLayoutDelegate protocol")
            return
        }
        
        guard let collectionView = collectionView else {
            return
        }
        
        assert(columnCount > 0, "WaterfallFlowLayout's columnCount should be greater than 0")
        
        // Initialize variables
        headersAttribute.removeAll(keepingCapacity: false)
        footersAttribute.removeAll(keepingCapacity: false)
        unionRects.removeAll(keepingCapacity: false)
        columnHeights.removeAll(keepingCapacity: false)
        allItemAttributes.removeAll(keepingCapacity: false)
        sectionItemAttributes.removeAll(keepingCapacity: false)
        
        for _ in 0..<columnCount {
            self.columnHeights.append(0)
        }
        
        // Create attributes
        var top: Float = 0
        var attributes: NSCollectionViewLayoutAttributes
        
        for section in 0..<numberOfSections {
            /*
             * 1. Get section-specific metrics (minimumInteritemSpacing, sectionInset)
             */
            let minimumInteritemSpacing: Float = delegate.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSection: section) ?? self.minimumInteritemSpacing
            
            let sectionInset: NSEdgeInsets = delegate.collectionView?(collectionView, layout: self, insetForSection: section) ?? self.sectionInset
            
            let width = Float(collectionView.frame.size.width - sectionInset.left - sectionInset.right)
            let itemWidth = floorf((width - Float(columnCount - 1) * Float(minimumColumnSpacing)) / Float(columnCount))
            
            /*
             * 2. Section header
             */
            let headerHeight: Float = delegate.collectionView?(collectionView, layout: self, heightForHeaderInSection: section) ?? self.headerHeight
            
            let headerInset: NSEdgeInsets = delegate.collectionView?(collectionView, layout: self, insetForHeaderInSection: section) ?? self.headerInset
            
            top += Float(headerInset.top)
            
            if headerHeight > 0 {
                attributes = NSCollectionViewLayoutAttributes(forSupplementaryViewOfKind: CollectionViewWaterfallElementKindSectionHeader, with: NSIndexPath(forItem: 0, inSection: section) as IndexPath)
                attributes.frame = CGRect(x: headerInset.left, y: CGFloat(top), width: collectionView.frame.size.width - (headerInset.left + headerInset.right), height: CGFloat(headerHeight))
                
                headersAttribute[section] = attributes
                allItemAttributes.append(attributes)
                
                top = Float(attributes.frame.maxY) + Float(headerInset.bottom)
            }
            
            top += Float(sectionInset.top)
            for idx in 0..<columnCount {
                columnHeights[idx] = top
            }
            
            
            /*
             * 3. Section items
             */
            let itemCount = collectionView.numberOfItems(inSection: section)
            var itemAttributes = [NSCollectionViewLayoutAttributes]()
            
            // Item will be put into shortest column.
            for idx in 0..<itemCount {
                let indexPath = NSIndexPath(forItem: idx, inSection: section)
                let columnIndex = shortestColumnIndex()
                
                let xOffset = Float(sectionInset.left) + Float(itemWidth + minimumColumnSpacing) * Float(columnIndex)
                let yOffset = columnHeights[columnIndex]
                let itemSize = delegate.collectionView(collectionView, layout: self, sizeForItemAtIndexPath: indexPath)
                var itemHeight: Float = 0.0
                if itemSize.height > 0 && itemSize.width > 0 {
                    itemHeight = Float(itemSize.height) * itemWidth / Float(itemSize.width)
                }
                
                attributes = NSCollectionViewLayoutAttributes(forItemWith: indexPath as IndexPath)
                attributes.frame = CGRect(x: CGFloat(xOffset), y: CGFloat(yOffset), width: CGFloat(itemWidth), height: CGFloat(itemHeight))
                itemAttributes.append(attributes)
                allItemAttributes.append(attributes)
                columnHeights[columnIndex] = Float(attributes.frame.maxY) + minimumInteritemSpacing
            }
            
            sectionItemAttributes.append(itemAttributes)
            
            /*
             * 4. Section footer
             */
            let columnIndex = longestColumnIndex()
            top = columnHeights[columnIndex] - minimumInteritemSpacing + Float(sectionInset.bottom)
            
            let footerHeight: Float = delegate.collectionView?(collectionView, layout: self, heightForFooterInSection: section) ?? self.footerHeight
            
            let footerInset: NSEdgeInsets = delegate.collectionView?(collectionView, layout: self, insetForFooterInSection: section) ?? self.footerInset
            
            top += Float(footerInset.top)
            
            if footerHeight > 0 {
                attributes = NSCollectionViewLayoutAttributes(forSupplementaryViewOfKind: CollectionViewWaterfallElementKindSectionFooter, with: NSIndexPath(forItem: 0, inSection: section) as IndexPath)
                attributes.frame = CGRect(x: footerInset.left, y: CGFloat(top), width: collectionView.frame.size.width - (footerInset.left + footerInset.right), height: CGFloat(footerHeight))
                
                footersAttribute[section] = attributes
                allItemAttributes.append(attributes)
                
                top = Float(attributes.frame.maxY) + Float(footerInset.bottom)
            }
            
            for idx in 0..<columnCount {
                columnHeights[idx] = top
            }
        }
        
        // Build union rects
        var idx = 0
        let itemCounts = allItemAttributes.count
        
        while idx < itemCounts {
            let rect1 = allItemAttributes[idx].frame
            idx = min(idx + unionSize, itemCounts) - 1
            let rect2 = allItemAttributes[idx].frame
            unionRects.append(rect1.union(rect2))
            idx += 1
        }
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        if indexPath.section >= sectionItemAttributes.count {
            return nil
        }
        
        if indexPath.item >= sectionItemAttributes[indexPath.section].count {
            return nil
        }
        
        return sectionItemAttributes[indexPath.section][indexPath.item]
    }
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        var attribute: NSCollectionViewLayoutAttributes?
        
        if elementKind == CollectionViewWaterfallElementKindSectionHeader {
            attribute = headersAttribute[indexPath.section]
        } else if elementKind == CollectionViewWaterfallElementKindSectionFooter {
            attribute = footersAttribute[indexPath.section]
        }
        
        return attribute
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [NSCollectionViewLayoutAttributes] {
        var begin: Int = 0
        var end: Int = unionRects.count
        var attrs = [NSCollectionViewLayoutAttributes]()
        
        for i in 0..<unionRects.count {
            if rect.intersects(unionRects[i]) {
                begin = i * unionSize
                break
            }
        }
        for i in (0..<unionRects.count).reversed() {
            if rect.intersects(unionRects[i]) {
                end = min((i+1) * unionSize, allItemAttributes.count)
                break
            }
        }
        for i in begin..<end {
            let attr = allItemAttributes[i]
            if rect.intersects(attr.frame) {
                attrs.append(attr)
            }
        }
        
        return Array(attrs)
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let oldBounds = collectionView?.bounds
        if newBounds.width != oldBounds?.width {
            return true
        }
        
        return false
    }
}


// MARK: - Private Methods
private extension HistoryThumbnailFlowLayout {
    func shortestColumnIndex() -> Int {
        var index: Int = 0
        var shortestHeight = MAXFLOAT
        
        for (idx, height) in columnHeights.enumerated() {
            if height < shortestHeight {
                shortestHeight = height
                index = idx
            }
        }
        
        return index
    }
    
    func longestColumnIndex() -> Int {
        var index: Int = 0
        var longestHeight:Float = 0
        
        for (idx, height) in columnHeights.enumerated() {
            if height > longestHeight {
                longestHeight = height
                index = idx
            }
        }
        
        return index
    }
    
    func invalidateIfNotEqual<T: Equatable>(_ oldValue: T, newValue: T) {
        if oldValue != newValue {
            invalidateLayout()
        }
    }
    
    func invalidateIfNotEqual_NSEdgeInsets(_ oldValue: NSEdgeInsets, newValue: NSEdgeInsets) {
        if oldValue.left != newValue.left || oldValue.top != newValue.top || oldValue.right != newValue.right || oldValue.bottom != newValue.bottom {
            invalidateLayout()
        }
    }
}
