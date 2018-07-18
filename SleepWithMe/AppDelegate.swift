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
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        NSUserNotificationCenter.default.delegate = self
        
        PutMeToSleep.load()
        
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

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            return false
        }
        let mainWC = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
            .instantiateInitialController() as! NSWindowController
        mainWC.showWindow(self)
        return true
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    public func setMenuBarTitle(_ title: String) {
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
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        if notification.activationType == .actionButtonClicked {
            (popover.contentViewController as? ViewController)?.stopTimer()
        } else if notification.activationType == .contentsClicked {
            showPopover(notification)
        }
    }
}
