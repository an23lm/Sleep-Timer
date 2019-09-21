//
//  NSTimerView.swift
//  SleepWithMe
//
//  Created by Ansèlm Joseph on 05/06/18.
//  Copyright © 2018 an23lm. All rights reserved.
//

import Cocoa

class NSTimerView: NSView {

    private var bgArc: CAShapeLayer! = nil
    private var fgArc: CAShapeLayer! = nil
    
    private(set) var fgArcStokeEnd: CGFloat = 0
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup(frameRect: frameRect)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup(frameRect: frame)
    }
    
    private func setup(frameRect: NSRect) {
        var rect = frameRect
        rect.origin = CGPoint.zero
        let center = NSPoint(x: rect.width/2, y: rect.width/2)
        
        wantsLayer = true
        
        let bgArcPath = NSBezierPath()
        bgArcPath.appendArc(
            withCenter: center,
            radius: (rect.width/2) - 5,
            startAngle: CGFloat(210),
            endAngle: CGFloat(330),
            clockwise: true)
        bgArcPath.lineCapStyle = .round
        
        bgArc = CAShapeLayer()
        bgArc.path = bgArcPath.cgPath
        bgArc.fillColor = CGColor.clear
        bgArc.strokeColor = CGColor(gray: 0.5, alpha: 0.5)
        bgArc.lineWidth = 5.0
        bgArc.strokeStart = 0
        bgArc.strokeEnd = 0
        bgArc.lineCap = CAShapeLayerLineCap.round
        
        let fgArcPath = NSBezierPath()
        fgArcPath.appendArc(
            withCenter: NSPoint(x: rect.width/2, y: rect.height/2),
            radius: rect.width/2 - 5,
            startAngle: CGFloat(210),
            endAngle: CGFloat(330),
            clockwise: true)
        
        fgArc = CAShapeLayer()
        fgArc.path = bgArcPath.cgPath
        fgArc.fillColor = CGColor.clear
        if #available(OSX 10.12, *) {
            fgArc.strokeColor = NSColor(displayP3Red: 238/256.0, green: 96/256.0, blue: 2/256.0, alpha: 1.0).cgColor
        } else {
            fgArc.strokeColor = NSColor(deviceRed: 238/256.0, green: 96/256.0, blue: 2/256.0, alpha: 1.0).cgColor
        }
        fgArc.lineWidth = 5.0
        fgArc.strokeStart = 0
        fgArc.strokeEnd = 0
        fgArc.lineCap = CAShapeLayerLineCap.round
        
        layer!.addSublayer(bgArc)
        layer!.addSublayer(fgArc)
        needsDisplay = true
    }
    
    func animateBackgroundArc(duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        bgArc.strokeEnd = 1.0
        bgArc.add(animation, forKey: "animateBgArc")
    }
    
    func animateForegroundArc(duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = fgArcStokeEnd
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        fgArc.strokeEnd = 1.0
        fgArcStokeEnd = 1.0
        fgArc.add(animation, forKey: "animateFgArc")
    }
    
    func moveForegorundArc(toPosition: CGFloat) {
        fgArc.strokeEnd = toPosition
        fgArcStokeEnd = toPosition
    }
    
    func animateForegroundArc(toPosition: CGFloat, fromPosition: CGFloat, duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = fromPosition
        animation.toValue = toPosition
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        fgArc.strokeEnd = toPosition
        fgArcStokeEnd = toPosition
        fgArc.add(animation, forKey: "animateFgArc")
    }
    
    func animateForegroundArc(toPosition position: CGFloat, duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = fgArcStokeEnd
        animation.toValue = position
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        fgArc.strokeEnd = position
        fgArcStokeEnd = position
        fgArc.add(animation, forKey: "animateFgArc")
    }
}

extension NSBezierPath {
    
    public var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            }
        }
        
        return path
    }
}
