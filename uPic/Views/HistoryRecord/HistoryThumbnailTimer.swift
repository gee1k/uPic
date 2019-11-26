//
//  HistoryThumbnailTimer.swift
//  uPic
//
//  Created by 侯猛 on 2019/11/26.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class HistoryThumbnailTimer {
    
    static let shared = HistoryThumbnailTimer()
    private init() {}
    
    /// 计时器
    private var _timer: DispatchSourceTimer?
    /// 计时器
    private var _scrollTimer: DispatchSourceTimer?
    
    func dispatchTimer(timeInterval: TimeInterval, handler:@escaping (DispatchSourceTimer)->()) {
        cancelTimer()
        if _timer?.isCancelled == false { return }
        let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        _timer = timer
        timer.schedule(wallDeadline: .now() + timeInterval, repeating: timeInterval)
        timer.setEventHandler(handler: {
            handler(timer)
        })
        timer.resume()
    }
    
    func dispatchScrollTimer(timeInterval: TimeInterval, handler:@escaping (DispatchSourceTimer)->()) {
        cancelTimer()
        if _scrollTimer?.isCancelled == false { return }
        let scrollTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        _scrollTimer = scrollTimer
        scrollTimer.schedule(wallDeadline: .now(), repeating: timeInterval)
        scrollTimer.setEventHandler(handler: {
            handler(scrollTimer)
        })
        scrollTimer.resume()
    }
    
    func cancelTimer() {
        _timer?.cancel()
    }
    
    func cancelScrollTimer() {
        _scrollTimer?.cancel()
    }
    
    func cancelAllTimer() {
        _timer?.cancel()
        _scrollTimer?.cancel()
    }
}
