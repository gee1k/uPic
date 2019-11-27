//
//  HistoryThumbnailConstant.swift
//  uPic
//
//  Created by 侯猛 on 2019/11/25.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

/// 历史记录总宽
var historyRecordViewWidthGlobal: CGFloat {
    return CGFloat(Defaults[.historyRecordWidth]!)
}
/// 预览图列数
var previewLineNumberGlobal: Int {
    return Defaults[.historyRecordColumns]!
}
/// 预览图间距
var previewLineSpacingGlobal: CGFloat {
    return CGFloat(Defaults[.historyRecordSpacing]!)
}
/// 历史记录内边距
var historyRecordLeftRightInsetGlobal: CGFloat {
    return CGFloat(Defaults[.historyRecordPadding]!)
}
/// 预览图宽度
var previewWidthGlobal: CGFloat {
    return (historyRecordViewWidthGlobal - CGFloat((previewLineNumberGlobal - 1)) * previewLineSpacingGlobal - historyRecordLeftRightInsetGlobal * 2) / CGFloat(previewLineNumberGlobal)
}
/// 预览图默认宽度
var previewDefaulWidthGlobal: CGFloat {
    return 300
}

/// 文件名滚动时间速度 s 单位
var fileNameScrollAnimationTime: TimeInterval {
    return (1 / Defaults[.historyRecordFileNameScrollSpeed]!)
}

/// 下次滚动等待时间
var fileNameScrollingTime: CGFloat {
    return CGFloat(Defaults[.historyRecordFileNameScrollWaitTime]!)
}
