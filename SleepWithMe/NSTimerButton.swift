//
//  NSTimerButton.swift
//  SleepWithMe
//
//  Created by Ansèlm Joseph on 06/06/18.
//  Copyright © 2018 an23lm. All rights reserved.
//

import Cocoa

@objc public enum NSTimerButtonStyle: Int {
    case increment
    case decrement
    case close
    case none
}

@IBDesignable
class NSTimerButton: NSButton {

    @IBInspectable var style: NSTimerButtonStyle = .none {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if style == .increment {
            let path = NSBezierPath()
            path.move(to: NSPoint(x: dirtyRect.width/2, y: 15))
            path.line(to: NSPoint(x: dirtyRect.width/2, y: dirtyRect.height - 15))
            path.move(to: NSPoint(x: 15, y: dirtyRect.height/2))
            path.line(to: NSPoint(x: dirtyRect.width - 15, y: dirtyRect.height/2))
            path.lineCapStyle = .roundLineCapStyle
            NSColor.white.setStroke()
            path.lineWidth = 3
            path.stroke()
        } else if style == .decrement {
            let path = NSBezierPath()
            path.move(to: NSPoint(x: 15, y: dirtyRect.height/2))
            path.line(to: NSPoint(x: dirtyRect.width - 15, y: dirtyRect.height/2))
            path.lineCapStyle = .roundLineCapStyle
            NSColor.white.setStroke()
            path.lineWidth = 3
            path.stroke()
        } else if style == .close {
            let path = NSBezierPath()
            path.move(to: NSPoint(x: 7, y: 7))
            path.line(to: NSPoint(x: dirtyRect.width - 7, y: dirtyRect.height - 7))
            path.move(to: NSPoint(x: 7, y: dirtyRect.height - 7))
            path.line(to: NSPoint(x: dirtyRect.width - 7, y: 7))
            path.lineCapStyle = .roundLineCapStyle
            NSColor.white.setStroke()
            path.lineWidth = 2
            path.stroke()
        }
        
    }
    
}
