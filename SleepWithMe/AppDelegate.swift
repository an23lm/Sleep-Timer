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

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let popover = NSPopover()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        if let statusButton = statusItem.button {
            statusButton.title = "Zzz"
            statusButton.action = #selector(togglePopover)
        }
        
        guard let vc = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ViewController")) as? ViewController else {
            assertionFailure()
            return
        }
        popover.contentViewController = vc
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc private func togglePopover(_ sender: Any) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    private func showPopover(_ sender: Any?) {
        if let statusButton = statusItem.button {
            popover.show(relativeTo: statusButton.bounds, of: statusButton, preferredEdge: NSRectEdge.minY)
        }
    }
    
    private func closePopover(_ sender: Any?) {
        popover.performClose(sender)
    }
}
