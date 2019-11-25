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
    return 500
}
/// 预览图列数
var previewLineNumberGlobal: Int {
    return 3
}
/// 预览图间距
var previewLineSpacingGlobal: CGFloat {
    return 5
}
/// 历史记录内边距
var historyRecordLeftRightInsetGlobal: CGFloat {
    return 5
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
    return 0.03
}
