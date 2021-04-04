//
//  PreferencesViewController.swift
//  SleepWithMe
//
//  Created by Ansèlm Joseph on 19/07/18.
//  Copyright © 2018 an23lm. All rights reserved.
//

import Cocoa
import Carbon

class PreferencesViewController: NSViewController {

    //MARK: - Outlet variables
    @IBOutlet weak var autoLaunchChecker: NSButton!
    @IBOutlet weak var showDockChecker: NSButton!
    @IBOutlet weak var defaultSleepTimerChecker: NSButton!
    @IBOutlet weak var defaultSleepTimerPicker: NSDatePicker!
    @IBOutlet weak var defaultTimerTextField: NSTextField!
    @IBOutlet weak var shortcutButton: NSButton!
    
    //MARK: - Helper variables
    var isAutoLaunchEnabled: Bool! = nil
    var isShowDockEnabled: Bool! = nil
    var isSleepTimerEnabled: Bool! = nil
    var sleepTime: Date! = nil
    var defaultTimer: Int! = nil
    
    var mouseMonitor: Any? = nil
    var keyMonitor: Any? = nil
    var flagMonitor: Any? = nil
    
    var shortcutModifierKeys: String = "" {
        didSet {
            shortcutKeybind = shortcutModifierKeys + shortcutCharKeys.uppercased()
        }
    }
    
    var shortcutCharKeys: String = "" {
        didSet {
            if shortcutModifierKeys.isEmpty {
                print("Shortcuts must start with at least one modifier key")
                shortcutKeybind = ""
            } else {
                shortcutKeybind = shortcutModifierKeys + shortcutCharKeys.uppercased()
            }
        }
    }
    
    var shortcutKeybind: String = "" {
        didSet {
            self.shortcutButton.title = shortcutKeybind
        }
    }
    
    var isGlobalShortcutListening: Bool {
        get {
            return shortcutButton.isHighlighted
        }
    }
    
    //MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isAutoLaunchEnabled = UserDefaults.standard.bool(forKey: Constants.autoLaunch)
        isShowDockEnabled = UserDefaults.standard.bool(forKey: Constants.isDockIconEnabled)
        isSleepTimerEnabled = UserDefaults.standard.bool(forKey: Constants.isSleepTimerEnabled)
        sleepTime = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: Constants.sleepTime))
        defaultTimer = UserDefaults.standard.integer(forKey: Constants.defaultTimer)
        shortcutKeybind = UserDefaults.standard.string(forKey: Constants.globalShortcutKeybind) ?? ""
        
        autoLaunchChecker.state = isAutoLaunchEnabled ? .on : .off
        showDockChecker.state = isShowDockEnabled ? .on : .off
        defaultSleepTimerChecker.state = isSleepTimerEnabled ? .on : .off
        defaultSleepTimerPicker.dateValue = sleepTime
        defaultTimerTextField.stringValue = String(defaultTimer)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.async {
            self.view.window?.makeFirstResponder(nil)
        }
        
        mouseMonitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) {
            if self.isGlobalShortcutListening {
                self.shortcutButton.highlight(false)
            }
            
            return $0
        }
        
        flagMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {
            guard let locWindow = self.view.window,
                NSApplication.shared.keyWindow === locWindow else { return $0 }

            self.flagsChanged(with: $0)

            return self.isGlobalShortcutListening ? nil : $0
        }
        
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            [weak self] (event) -> NSEvent? in

            guard self != nil else {
                return event
            }

            if event.keyCode == 53 && self!.isGlobalShortcutListening {
                DispatchQueue.main.async {
                    self?.shortcutButton.highlight(false)
                }
                return nil
            }

            guard event.charactersIgnoringModifiers != nil && self!.isGlobalShortcutListening else {
                return event
            }
            
            print(event.charactersIgnoringModifiers!)
            
            self!.shortcutCharKeys = event.charactersIgnoringModifiers!
            
            if self!.shortcutModifierKeys.isEmpty {
                return event
            } else {
                DispatchQueue.main.async {
                    self!.shortcutButton.highlight(false)
                }
                return nil
            }
        }
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        if (keyMonitor != nil) {
            NSEvent.removeMonitor(keyMonitor!)
        }
        if (flagMonitor != nil) {
            NSEvent.removeMonitor(flagMonitor!)
        }
        if (mouseMonitor != nil) {
            NSEvent.removeMonitor(mouseMonitor!)
        }
    }
    
    override func flagsChanged(with event: NSEvent) {
        if (self.isGlobalShortcutListening) {
            print(event.modifierFlags.intersection(.deviceIndependentFlagsMask).description)
            shortcutModifierKeys = event.modifierFlags.intersection(.deviceIndependentFlagsMask).description
        }
    }
    
    
    //MARK: - Actions
    
    @IBAction func shortcutButtonOnPress(_ sender: Any) {
        self.shortcutCharKeys = ""
        self.shortcutModifierKeys = ""
        view.window?.makeFirstResponder(nil)
        
        DispatchQueue.main.async {
            self.shortcutButton.highlight(true)
        }
    }
    
    @IBAction func clearShortcutButtonOnPress(_ sender: Any) {
        self.shortcutCharKeys = ""
        self.shortcutModifierKeys = ""
    }
    
    @IBAction func doneButton(_ sender: Any) {
        isAutoLaunchEnabled = getBoolean(forState: autoLaunchChecker.state)
        isShowDockEnabled = getBoolean(forState: showDockChecker.state)
        isSleepTimerEnabled = getBoolean(forState: defaultSleepTimerChecker.state)
        sleepTime = defaultSleepTimerPicker.dateValue
        
        if defaultTimerTextField.stringValue.trimmingCharacters(in: .whitespaces) == "" {
            defaultTimer = 0
        } else {
            defaultTimer = Int(defaultTimerTextField.stringValue.trimmingCharacters(in: .whitespaces))!
        }
        
        UserDefaults.standard.set(isAutoLaunchEnabled, forKey: Constants.autoLaunch)
        UserDefaults.standard.set(isShowDockEnabled, forKey: Constants.isDockIconEnabled)
        UserDefaults.standard.set(isSleepTimerEnabled, forKey: Constants.isSleepTimerEnabled)
        let ti: Double = sleepTime.timeIntervalSince1970
        UserDefaults.standard.set(ti, forKey: Constants.sleepTime)
        UserDefaults.standard.set(defaultTimer, forKey: Constants.defaultTimer)
        UserDefaults.standard.set(shortcutKeybind, forKey: Constants.globalShortcutKeybind)
        UserDefaults.standard.synchronize()
        
        if (isShowDockEnabled) {
            NSApplication.shared.setActivationPolicy(.regular)
        } else {
            NSApplication.shared.setActivationPolicy(.accessory)
        }
        
        (NSApplication.shared.delegate as! AppDelegate).loadPreferences()
        NSApplication.shared.mainWindow?.close()
    }
    
    //MARK: - Private helper methods
    private func getBoolean(forState state: NSControl.StateValue) -> Bool {
        switch state {
        case .on:
            return true
        case .off:
            return false
        default:
            return false
        }
    }
}
