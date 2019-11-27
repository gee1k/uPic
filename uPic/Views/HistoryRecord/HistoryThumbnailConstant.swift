//
//  HistoryThumbnailConstant.swift
//  uPic
//
//  Created by 侯猛 on 2019/11/25.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

/// 历史记录总宽
var HistoryRecordWidthGlobal: CGFloat {
    guard let width = Defaults[.historyRecordWidth], width > 0 else {
        return 500
    }
    return CGFloat(width)
}
/// 预览图列数
var HistoryRecordColumnsGlobal: Int {
    guard let columns = Defaults[.historyRecordColumns], columns > 0 else {
        return 3
    }
    return columns
}
/// 预览图间距
var HistoryRecordSpacingGlobal: CGFloat {
    guard let spacing = Defaults[.historyRecordSpacing], spacing > 0 else {
        return 5
    }
    return CGFloat(spacing)
}
/// 历史记录内边距
var HistoryRecordPaddingGlobal: CGFloat {
    guard let inset = Defaults[.historyRecordPadding], inset > 0 else {
        return 5
    }
    return CGFloat(inset)
}
/// 预览图宽度
var PreviewWidthGlobal: CGFloat {
    return (HistoryRecordWidthGlobal - CGFloat((HistoryRecordColumnsGlobal - 1)) * HistoryRecordSpacingGlobal - HistoryRecordPaddingGlobal * 2) / CGFloat(HistoryRecordColumnsGlobal)
}
/// 预览图默认宽度
var PreviewDefaulWidthGlobal: CGFloat {
    return HistoryRecordWidthGlobal - HistoryRecordPaddingGlobal * 2
}

/// 文件名滚动速率百分比 1s 为基数
var HistoryRecordFileNameScrollSpeedGlobal: TimeInterval {
    guard let speed = Defaults[.historyRecordFileNameScrollSpeed], speed > 0 else {
        return 30
    }
    return speed
}

var HistoryRecordFileNameScrollSpeed: TimeInterval {
    return 1 * (HistoryRecordFileNameScrollSpeedGlobal / 1000)
}

/// 下次滚动等待时间
var HistoryRecordFileNameScrollWaitTimeGlobal: CGFloat {
    guard let time = Defaults[.historyRecordFileNameScrollWaitTime], time > 0 else {
        return 1
    }
    return CGFloat(time)
}
