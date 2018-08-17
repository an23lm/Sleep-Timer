//
//  AppDelegate.swift
//  SleepWithMe
//
//  Created by Ansèlm Joseph on 05/06/18.
//  Copyright © 2018 an23lm. All rights reserved.
//

import Cocoa
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var popover: NSPopover! = nil
    var eventMonitor: EventMonitor?
    
    let textField = NSTextField()
    let imageView = NSImageView()
    
    private(set) var sleepTimer: SleepTimer! = nil
    private var scheduledSleepTimer: Timer? = nil
    private var defaultTimer: Int = 0
    
    private var notification: NSUserNotification? = nil
    
    private var preferences: (autoLaunchEnabled: Bool, isDockEnabled: Bool, isScheduledSleepTimerEnabled: Bool, scheduledSleepTime: Date, defaultTimer: Int)! = (false, true, false, Date(timeIntervalSince1970: 0), 0)
    
    //MARK: - Life cycle methods
    func applicationWillFinishLaunching(_ notification: Notification) {
        self.sleepTimer = SleepTimer()
        SleepTimer.shared = self.sleepTimer
        SleepTimer.shared.onTimeRemainingChange(onTimeRemainingChange)
        SleepTimer.shared.onTimerActivated(onTimerActivated)
        SleepTimer.shared.onTimerInvalidated(onTimerInvalidated)
        
        firstLaunch()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(willSleepNotification(notification:)), name: NSWorkspace.willSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(didWakeNotification(notification:)), name: NSWorkspace.didWakeNotification, object: nil)
        NSUserNotificationCenter.default.delegate = self
        PutMeToSleep.load()
        setupPopoverAsset()
        setupMenuBarAsset()
        loadPreferences()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            return true
        }
        if preferences.isDockEnabled {
            let mainWC = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
                .instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "MainWindowController")) as! NSWindowController
            mainWC.showWindow(self)
        } else {
            togglePopover(sender)
        }
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
    
    @objc func willSleepNotification(notification: NSNotification) {
        print("will sleep")
        if SleepTimer.shared.isTimerRunning {
            SleepTimer.shared.toggleTimer()
        }
        scheduledSleepTimer?.invalidate()
        scheduledSleepTimer = nil
        preferences.scheduledSleepTime = Date(timeIntervalSince1970: 0)
        NSUserNotificationCenter.default.removeAllDeliveredNotifications()
    }
    
    @objc func didWakeNotification(notification: NSNotification) {
        print("did wake")
        if preferences.isScheduledSleepTimerEnabled {
            print("did wak1e")
            setupScheduledSleepTimer()
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
            SleepTimer.shared.set(minutes: (self?.defaultTimer) ?? 0)
            self?.sush()
        } else {
            self?.setMenuBarTitle("")
        }
    }
    
    //MARK: - Helper methods
    private func sendNotification(withCurrentMinutes currentMinutes: Int) {
        NSUserNotificationCenter.default.removeAllDeliveredNotifications()
        
        notification = NSUserNotification()
        notification!.title = "\(currentMinutes) mins to ZZZ"
        notification!.informativeText = "Sleep With Me will put your Mac to sleep with you in \(currentMinutes) mins."
        notification!.soundName = nil
        notification!.hasActionButton = true
        notification!.actionButtonTitle = "Stop Timer"
        
        let center = NSUserNotificationCenter.default
        center.deliver(notification!)
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
        popover = NSPopover()
        guard let vc = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ViewController")) as? ViewController else {
            assertionFailure()
            return
        }
        vc.isPopover = true
        popover.contentViewController = vc
        popover.animates = true
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(event)
            }
        }
    }
    
    private func firstLaunch() {
        guard !UserDefaults.standard.bool(forKey: Constants.notFirstLaunch) else {
            return
        }
        UserDefaults.standard.set(true, forKey: Constants.notFirstLaunch)
        UserDefaults.standard.set(false, forKey: Constants.autoLaunch)
        UserDefaults.standard.set(true, forKey: Constants.isDockIconEnabled)
        UserDefaults.standard.set(false, forKey: Constants.isSleepTimerEnabled)
        let date = Date(timeIntervalSince1970: 0)
        let ti: Double = date.timeIntervalSince1970
        UserDefaults.standard.set(ti, forKey: Constants.sleepTime)
        UserDefaults.standard.set(0, forKey: Constants.defaultTimer)
        UserDefaults.standard.synchronize()
    }
    
    func setupScheduledSleepTimer() {
        let sleepTime = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: Constants.sleepTime))
        guard sleepTime != preferences.scheduledSleepTime else {
            return
        }
        preferences.scheduledSleepTime = sleepTime
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: sleepTime)
        let todayComponents = Calendar.current.dateComponents([.hour, .minute], from: Date())
        var selectDate = Date()
        
        if components.hour! < todayComponents.hour! {
            selectDate = Calendar.current.date(byAdding: .day, value: 1, to: selectDate)!
        } else if components.hour! == todayComponents.hour! && components.minute! <= todayComponents.minute! {
            selectDate = Calendar.current.date(byAdding: .day, value: 1, to: selectDate)!
        }
        
        let date = Calendar.current.date(bySettingHour: components.hour!, minute: components.minute!, second: 0, of: selectDate)!
        
        let diff = Calendar.current.dateComponents([.day, .hour, .minute], from: Date(), to: date)
        print(diff)
        if diff.day! == 0 && diff.hour! == 0 && diff.minute! <= 30 {
            self.autoSleep(minutes: diff.minute!)
        } else {
            let fDate = Calendar.current.date(byAdding: .minute, value: -30, to: date)!
            if #available(OSX 10.12, *) {
                scheduledSleepTimer?.invalidate()
                scheduledSleepTimer = Timer(fire: fDate, interval: 86400, repeats: true) { (timer) in
                    self.autoSleep(minutes: 30)
                }
                RunLoop.current.add(scheduledSleepTimer!, forMode: .defaultRunLoopMode)
            } else {
                scheduledSleepTimer?.invalidate()
                scheduledSleepTimer = Timer(fireAt: fDate, interval: 86400, target: self, selector: #selector(autoSleep(_:)), userInfo: nil, repeats: true)
                RunLoop.current.add(scheduledSleepTimer!, forMode: .defaultRunLoopMode)
            }
        }
    }
    
    internal func loadPreferences() {
        preferences.autoLaunchEnabled = UserDefaults.standard.bool(forKey: Constants.autoLaunch)
        setLaunchOnLogin()
        if UserDefaults.standard.bool(forKey: Constants.isDockIconEnabled) {
            NSApplication.shared.setActivationPolicy(.regular)
            preferences.isDockEnabled = true
        } else {
            NSApplication.shared.setActivationPolicy(.accessory)
            preferences.isDockEnabled = false
        }
        if UserDefaults.standard.bool(forKey: Constants.isSleepTimerEnabled) {
            preferences.isScheduledSleepTimerEnabled = true
            setupScheduledSleepTimer()
        } else {
            preferences.isScheduledSleepTimerEnabled = false
            preferences.scheduledSleepTime = Date(timeIntervalSince1970: 0)
            scheduledSleepTimer?.invalidate()
        }
        if !SleepTimer.shared.isTimerRunning {
            defaultTimer = UserDefaults.standard.integer(forKey: Constants.defaultTimer)
            preferences.defaultTimer = defaultTimer
            SleepTimer.shared.set(minutes: defaultTimer)
        }
    }

    @objc func autoSleep(_ sender: Any) {
        autoSleep(minutes: 30)
    }
    
    func autoSleep(minutes: Int) {
        if !SleepTimer.shared.isTimerRunning {
            SleepTimer.shared.set(minutes: minutes)
            SleepTimer.shared.toggleTimer()
            sendNotification(withCurrentMinutes: minutes)
        }
    }
    
    func setLaunchOnLogin() {
        let appBundleIdentifier: CFString = "com.an23lm.SleepWithMeHelper" as CFString
        SMLoginItemSetEnabled(appBundleIdentifier, preferences.autoLaunchEnabled)
    }
}
