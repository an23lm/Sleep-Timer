//
//  AppDelegate.swift
//  SleepWithMe
//
//  Created by Ansèlm Joseph on 05/06/18.
//  Copyright © 2018 an23lm. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let popover = NSPopover()
    var eventMonitor: EventMonitor?
    
    let textField = NSTextField()
    let imageView = NSImageView()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
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

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    public func setMenuBarTitle(_ title: String) {
        textField.stringValue = title
        textField.sizeToFit()
        statusItem.length = imageView.frame.width + textField.frame.width
        imageView.frame.origin.x = textField.frame.width
    }
    
    @objc private func togglePopover(_ sender: Any) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    private func showPopover(_ sender: Any?) {
        if statusItem.button != nil {
            popover.show(relativeTo: NSRect(origin: CGPoint(x: statusItem.length, y: 0), size: CGSize.zero), of: imageView, preferredEdge: NSRectEdge.maxY)
            eventMonitor?.start()
        }
    }
    
    private func closePopover(_ sender: Any?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
}
