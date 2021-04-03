//
//  MenuBarView.swift
//  SleepWithMe
//
//  Created by Anselm Joseph on 19/04/20.
//  Copyright © 2020 an23lm. All rights reserved.
//

import Cocoa

class MenuBarView: NSView {
    var titleTextField: NSTextField!
    var timerTextField: NSTextField!
    var borderView: NSBox!
    var effectiveAppearanceObserver: Any!
    
    weak var appDelegate = (NSApp.delegate as! AppDelegate)
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup(frameRect: frameRect)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup(frameRect: frame)
    }
    
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        
        SleepTimer.shared.onTimeRemainingChange(onTimeRemainingChange)
        SleepTimer.shared.onTimerActivated(onTimerActivated)
        SleepTimer.shared.onTimerInvalidated(onTimerInvalidated)
        
//        if #available(OSX 10.14, *) {
//            self.effectiveAppearanceObserver = NSApp.observe(\.effectiveAppearance) { _, _ in
//                print(self.effectiveAppearance)
//            }
//        } else {
//            DistributedNotificationCenter.default().addObserver(self, selector: #selector(didChangeToSystemTheme),
//                                                                name: NSNotification.Name("AppleInterfaceThemeChangedNotification"),
//                                                                object: nil)
//        }
    }
    
    lazy var onTimeRemainingChange: SleepTimer.onTimeRemainingCallback = {[weak self] (minutes) in
        self?.timerTextField.stringValue = "\(minutes)"
    }
    
    lazy var onTimerActivated: SleepTimer.onTimerActivatedCallback = {[weak self] in
        let timerRect = CGRect(x: 16, y: 0, width: 32, height: 18)
        self?.timerTextField.setFrameOrigin(timerRect.origin)
        self?.timerTextField.setFrameSize(timerRect.size)
        self?.animate(width: 50, duration: 0.5)
        self?.animateTimerTextField(alpha: 1.0, duration: 0.5)
    }
    
    lazy var onTimerInvalidated: SleepTimer.onTimerInvalidatedCallback = {[weak self] (didComplete) in
        self?.animate(width: 20, duration: 0.5)
        self?.animateTimerTextField(alpha: 0.0, duration: 0.5)
    }
    
//    @objc func didChangeToSystemTheme(_ notification: NSNotification) {
//        if (InterfaceStyle.current == .Dark) {
//            layer!.borderColor = CGColor.white
//        } else {
//            layer!.borderColor = CGColor.black
//        }
//    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        layer?.borderColor = NSColor.labelColor.cgColor
        appDelegate?.statusItem.length = dirtyRect.size.width + 8
    }
    
    private func animate(width: Int, duration: Double) {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = duration
        self.animator().setFrameSize(NSSize(width: width, height: 18))
        NSAnimationContext.endGrouping()
        self.animator().setFrameSize(NSSize(width: width, height: 18))
    }
    
    private func animateTimerTextField(alpha: CGFloat, duration: Double) {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = duration
        timerTextField.animator().alphaValue = alpha
        NSAnimationContext.endGrouping()
        timerTextField.alphaValue = alpha
    }
    
    private func setup(frameRect: CGRect) {
        var titleRect = frameRect
        titleRect.origin = CGPoint(x: 4, y: 0)
        titleTextField = NSTextField(frame: titleRect)
        titleTextField.stringValue = "Z"
        titleTextField.isEditable = false
        titleTextField.isBezeled = false
        titleTextField.isBordered = false
        titleTextField.isSelectable = false
        titleTextField.drawsBackground = true
        titleTextField.textColor = NSColor.labelColor
        titleTextField.backgroundColor = NSColor(cgColor: CGColor(gray: 0.0, alpha: 0.0))
        if #available(OSX 10.15, *) {
            let descriptor = NSFont.systemFont(ofSize: 12, weight: .heavy).fontDescriptor.withDesign(.rounded)
            titleTextField.font = NSFont(descriptor: descriptor!, size: 0)
        } else {
            titleTextField.font = NSFont.systemFont(ofSize: 12, weight: .heavy)
        }
        
        let timerRect = CGRect.zero
        timerTextField = NSTextField(frame: timerRect)
        timerTextField.stringValue = ""
        timerTextField.isEditable = false
        timerTextField.isBezeled = false
        timerTextField.isBordered = false
        timerTextField.isSelectable = false
        timerTextField.drawsBackground = true
        timerTextField.alphaValue = 0
        timerTextField.textColor = NSColor.labelColor
        timerTextField.backgroundColor = NSColor(cgColor: CGColor(gray: 0.0, alpha: 0.0))
        timerTextField.usesSingleLineMode = true
        timerTextField.lineBreakMode = .byTruncatingTail
        timerTextField.alignment = .center
        if #available(OSX 10.15, *) {
            let descriptor = NSFont.systemFont(ofSize: 12, weight: .heavy).fontDescriptor.withDesign(.rounded)
            timerTextField.font = NSFont(descriptor: descriptor!, size: 0)
        } else {
            timerTextField.font = NSFont.systemFont(ofSize: 12, weight: .heavy)
        }
        
        self.addSubview(titleTextField)
        self.addSubview(timerTextField)
        
        wantsLayer = true
        
        layer!.borderWidth = 2
        layer!.cornerRadius = 5
    }
}
