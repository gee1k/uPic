//
//  NSButtonExtension.swift
//  uPic
//
//  Created by 侯猛 on 2019/11/1.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import Foundation

extension NSButton {
    
    struct AssociatedClosureClass {
        var eventClosure: (NSButton) -> Void
    }
    
    private struct AssociatedKeys {
        static var eventClosureObj:AssociatedClosureClass?
    }
    
    private var eventClosureObj: AssociatedClosureClass{
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.eventClosureObj, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            return (objc_getAssociatedObject(self, &AssociatedKeys.eventClosureObj) as? AssociatedClosureClass)!
        }
    }
    
    func addTarget(action:@escaping (NSButton) -> Void ) {
        let eventObj = AssociatedClosureClass(eventClosure: action)
        eventClosureObj = eventObj
        target = self
        self.action = #selector(eventExcuate(_:))
    }
    
    @objc private func eventExcuate(_ sender: NSButton){
        eventClosureObj.eventClosure(sender)
    }
    
}
