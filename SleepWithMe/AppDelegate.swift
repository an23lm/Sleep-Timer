//
//  AppDelegate.swift
//  SleepWithMe
//
//  Created by Ansèlm Joseph on 05/06/18.
//  Copyright © 2018 an23lm. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let popover = NSPopover()
    var eventMonitor: EventMonitor?
    
    let textField = NSTextField()
    let imageView = NSImageView()
    
    private(set) var sleepTimer: SleepTimer! = nil
    
    //MARK: - Life cycle methods
    func applicationWillFinishLaunching(_ notification: Notification) {
        self.sleepTimer = SleepTimer()
        SleepTimer.shared = self.sleepTimer
        
        SleepTimer.shared.onTimeRemainingChange(onTimeRemainingChange)
        SleepTimer.shared.onTimerActivated(onTimerActivated)
        SleepTimer.shared.onTimerInvalidated(onTimerInvalidated)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSUserNotificationCenter.default.delegate = self
        PutMeToSleep.load()
        setupMenuBarAsset()
        setupPopoverAsset()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            return true
        }
        let mainWC = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
            .instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "MainWindowController")) as! NSWindowController
        mainWC.showWindow(self)
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        if notification.activationType == .actionButtonClicked {
            SleepTimer.shared.stopTimer(didComplete: false)
            showPopover(notification)
        } else if notification.activationType == .contentsClicked {
            showPopover(notification)
        }
    }
    
    //MARK: - Callback closures
    lazy var onTimeRemainingChange: SleepTimer.onTimeRemainingCallback = {[weak self] (minutes) in
        if SleepTimer.shared.isTimerRunning {
            self?.setMenuBarTitle(String(minutes))
            if minutes == 5 && SleepTimer.shared.isTimerRunning {
                self?.sendNotification(withCurrentMinutes: minutes)
            }
        } else {
            self?.setMenuBarTitle("")
        }
    }
    
    lazy var onTimerActivated: SleepTimer.onTimerActivatedCallback = {[weak self] in
        self?.setMenuBarTitle(String(SleepTimer.shared.currentMinutes))
    }
    
    lazy var onTimerInvalidated: SleepTimer.onTimerInvalidatedCallback = {[weak self] (didComplete) in
        if didComplete {
            self?.sush()
        } else {
            self?.setMenuBarTitle("")
        }
    }
    
    //MARK: - Helper methods
    private func sendNotification(withCurrentMinutes currentMinutes: Int) {
        let notif = NSUserNotification()
        notif.title = "\(currentMinutes) mins to zzz"
        notif.informativeText = "SleepWithMe will put your Mac to sleep with you in \(currentMinutes) mins."
        notif.soundName = nil
        notif.hasActionButton = true
        notif.actionButtonTitle = "Stop Timer"
        
        let center = NSUserNotificationCenter.default
        center.deliver(notif)
    }
    
    private func sush() {
        let putMeToSleep = PutMeToSleep.getObject() as! AppleScriptProtocol
        putMeToSleep.sush()
    }

    private func setMenuBarTitle(_ title: String) {
        textField.stringValue = title
        textField.sizeToFit()
        if title == "" {
            statusItem.length = 40
            imageView.frame.origin.x = (imageView.frame.width - statusItem.length)/2
        } else if (imageView.frame.width + textField.frame.width) <= 65 {
            statusItem.length = 65
            let tLen = textField.frame.width + imageView.frame.width
            textField.frame.origin.x = (statusItem.length - tLen) / 2
            imageView.frame.origin.x = textField.frame.origin.x + textField.frame.width
        } else if (imageView.frame.width + textField.frame.width) <= 70 {
            statusItem.length = 70
            let tLen = textField.frame.width + imageView.frame.width
            textField.frame.origin.x = (statusItem.length - tLen) / 2
            imageView.frame.origin.x = textField.frame.origin.x + textField.frame.width
        } else {
            let tLen = textField.frame.width + imageView.frame.width
            statusItem.length = tLen
            textField.frame.origin.x = (statusItem.length - tLen) / 2
            imageView.frame.origin.x = textField.frame.origin.x + textField.frame.width
        }
    }
    
    @objc internal func togglePopover(_ sender: Any) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    internal func showPopover(_ sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            eventMonitor?.start()
        }
    }
    
    internal func closePopover(_ sender: Any?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    private func setupMenuBarAsset() {
        func loadImageView() {
            let image = NSImage(named: NSImage.Name.init(rawValue: "MenuBarIconTemplate"))
            imageView.frame = NSRect(origin: CGPoint(x: 0, y: 2), size: CGSize(width: 40, height: 18))
            imageView.image = image
            imageView.imageAlignment = .alignCenter
        }
        
        func loadTextField() {
            textField.frame = NSRect(origin: CGPoint(x: 5, y: 1), size: CGSize.zero)
            textField.font = NSFont.systemFont(ofSize: 15, weight: .regular)
            textField.isEditable = false
            textField.isBordered = false
            textField.isBezeled = false
            textField.drawsBackground = false
            setMenuBarTitle("")
            textField.sizeToFit()
        }
        
        if let statusButton = statusItem.button {
            loadImageView()
            loadTextField()
            
            statusButton.addSubview(imageView)
            statusButton.addSubview(textField)
            statusButton.action = #selector(togglePopover)
        }
    }
    
    private func setupPopoverAsset() {
        guard let vc = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ViewController")) as? ViewController else {
            assertionFailure()
            return
        }
        popover.contentViewController = vc
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(event)
            }
        }
    }
}
