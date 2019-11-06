//
//  PreviewFlowLayout.swift
//  uPic
//
//  Created by 侯猛 on 2019/10/23.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

public protocol HistoryThumbnailFlowLayoutDelegate: NSCollectionViewDelegate {
    
    /// return height for item at indexPath
    func collectionView(_ collectionView: NSCollectionView, itemWidth: CGFloat,  heightForItemAt indexPath: IndexPath) -> CGFloat
}

class HistoryThumbnailFlowLayout: NSCollectionViewFlowLayout {
    /// 列
    public var columnCount = 3
    /// 列间距
    public var columnSpacing: CGFloat = 0
    /// 行间距
    public var lineSpacing: CGFloat = 0
    public var edgeInset = NSEdgeInsetsZero
    
    private var contentHeight:CGFloat = 0.0
    private var columnHeights:[CGFloat] = []

    private var attrsArray:[NSCollectionViewLayoutAttributes] = []
    
    override func prepare() {
        super.prepare()
        contentHeight = 0
        columnHeights.removeAll()
        
        for _ in 0..<columnCount {
            columnHeights.append(self.edgeInset.top)
        }
        
        
        attrsArray.removeAll()
        let count = collectionView?.numberOfItems(inSection: 0)
        
        
        for index in 0..<(count ?? 0) {
            let indexPath = IndexPath(item: index, section: 0)
            let attrs = layoutAttributesForItem(at: indexPath)
            if let tempAttrs = attrs {
                attrsArray.append(tempAttrs)
            }
            
        }
    }
    
    
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        let attrs = super.layoutAttributesForItem(at: indexPath)
        
        let collectionViewW = collectionView?.frame.width ?? 0
        let width = (collectionViewW - edgeInset.left - edgeInset.right - (CGFloat(columnCount) - 1) * columnSpacing) / CGFloat(columnCount)
        
        let layoutDelegate = collectionView?.delegate as? HistoryThumbnailFlowLayoutDelegate
        let height: CGFloat = layoutDelegate?.collectionView(collectionView!, itemWidth: width, heightForItemAt: indexPath) ?? 44
        
        
        var destColumn = 0
        var minColumnHeight = columnHeights[destColumn]
        
        for index in 1..<columnCount {
            let columnHeight = columnHeights[index]
            if minColumnHeight > columnHeight {
                minColumnHeight = columnHeight
                destColumn = index
            }
        }
        
        
        let x = edgeInset.left + CGFloat(destColumn) * (width + columnSpacing)
        var y = minColumnHeight
        if y != edgeInset.top {
            y += lineSpacing
        }
        
        attrs?.frame = CGRect(x: x, y: y, width: width, height: height)
        
        
        columnHeights[destColumn] = attrs?.frame.maxY ?? 0
        let columnHeight = columnHeights[destColumn]
        if contentHeight < columnHeight {
            contentHeight = columnHeight
        }
        
        return attrs
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [NSCollectionViewLayoutAttributes] {
        var rectArray:[NSCollectionViewLayoutAttributes] = []
        for cacheAttr in attrsArray {
            if cacheAttr.frame.intersects(rect) {
                rectArray.append(cacheAttr)
            }
        }
        return rectArray
    }
    
    public override var collectionViewContentSize: CGSize {
        return CGSize(width: collectionView?.bounds.width ?? 0, height: contentHeight + edgeInset.bottom)
    }
    
}
