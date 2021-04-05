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
    var isAutoLaunchEnabled: Bool! = nil {
        didSet {
            DispatchQueue.main.async {
                self.autoLaunchChecker.state = self.isAutoLaunchEnabled ? .on : .off
            }
        }
    }
    var isShowDockEnabled: Bool! = nil {
        didSet {
            DispatchQueue.main.async {
                self.showDockChecker.state = self.isShowDockEnabled ? .on : .off
            }
        }
    }
    var isSleepTimerEnabled: Bool! = nil {
        didSet {
            DispatchQueue.main.async {
                self.defaultSleepTimerChecker.state = self.isSleepTimerEnabled ? .on : .off
            }
        }
    }
    var sleepTime: Date! = nil {
        didSet {
            DispatchQueue.main.async {
                self.defaultSleepTimerPicker.dateValue = self.sleepTime
            }
        }
    }
    var defaultTimer: Int! = nil {
        didSet {
            DispatchQueue.main.async {
                self.defaultTimerTextField.stringValue = String(self.defaultTimer)
            }
        }
    }
    var shortcutKeybind: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.shortcutButton.title = self.shortcutKeybind
            }
        }
    }
    
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
    
    var isGlobalShortcutListening: Bool {
        get {
            return shortcutButton.isHighlighted
        }
    }
    
    var mouseMonitor: Any? = nil
    var keyMonitor: Any? = nil
    var flagMonitor: Any? = nil
    
    //MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let preferences = loadPreferencesFromStorage()
        isAutoLaunchEnabled = preferences.isAutoLaunchEnabled
        isShowDockEnabled = preferences.isShowDockEnabled
        isSleepTimerEnabled = preferences.isSleepTimerEnabled
        sleepTime = preferences.sleepTimer
        defaultTimer = preferences.defaultTimer
        shortcutKeybind = preferences.shortcutKeybind
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.async {
            self.view.window?.makeFirstResponder(nil)
        }
        
        self.view.window?.delegate = self
        
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
        savePreferences()
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
    
    private func loadPreferencesFromStorage() -> (isAutoLaunchEnabled: Bool, isShowDockEnabled: Bool, isSleepTimerEnabled: Bool, sleepTimer: Date, defaultTimer: Int, shortcutKeybind: String){
        let isAutoLaunchEnabled = UserDefaults.standard.bool(forKey: Constants.autoLaunch)
        let isShowDockEnabled = UserDefaults.standard.bool(forKey: Constants.isDockIconEnabled)
        let isSleepTimerEnabled = UserDefaults.standard.bool(forKey: Constants.isSleepTimerEnabled)
        let sleepTime = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: Constants.sleepTime))
        let defaultTimer = UserDefaults.standard.integer(forKey: Constants.defaultTimer)
        let shortcutKeybind = UserDefaults.standard.string(forKey: Constants.globalShortcutKeybind) ?? ""
        
        return (isAutoLaunchEnabled, isShowDockEnabled, isSleepTimerEnabled, sleepTime, defaultTimer, shortcutKeybind)
    }
    
    private func didPreferencesChange() -> Bool {
        updateLocalPreferenceVariables()
        let oldPreferences = loadPreferencesFromStorage()
        let newPreferences = (isAutoLaunchEnabled, isShowDockEnabled, isSleepTimerEnabled, sleepTime, defaultTimer, shortcutKeybind)
    
        return oldPreferences != newPreferences
    }
    
    private func savePreferences() {
        updateLocalPreferenceVariables()
        
        UserDefaults.standard.set(isAutoLaunchEnabled, forKey: Constants.autoLaunch)
        UserDefaults.standard.set(isShowDockEnabled, forKey: Constants.isDockIconEnabled)
        UserDefaults.standard.set(isSleepTimerEnabled, forKey: Constants.isSleepTimerEnabled)
        let sleepTimeEpoch: Double = sleepTime.timeIntervalSince1970
        UserDefaults.standard.set(sleepTimeEpoch, forKey: Constants.sleepTime)
        UserDefaults.standard.set(defaultTimer, forKey: Constants.defaultTimer)
        UserDefaults.standard.set(shortcutKeybind, forKey: Constants.globalShortcutKeybind)
        UserDefaults.standard.synchronize()
        
        refreshApplicationPreferences()
    }
    
    private func updateLocalPreferenceVariables() {
        isAutoLaunchEnabled = getBoolean(forState: autoLaunchChecker.state)
        isShowDockEnabled = getBoolean(forState: showDockChecker.state)
        isSleepTimerEnabled = getBoolean(forState: defaultSleepTimerChecker.state)
        sleepTime = defaultSleepTimerPicker.dateValue
        
        if defaultTimerTextField.stringValue.trimmingCharacters(in: .whitespaces) == "" {
            defaultTimer = 0
        } else {
            defaultTimer = Int(defaultTimerTextField.stringValue.trimmingCharacters(in: .whitespaces))!
        }
        
    }
    
    private func refreshApplicationPreferences() {
        if (isShowDockEnabled) {
            NSApplication.shared.setActivationPolicy(.regular)
        } else {
            NSApplication.shared.setActivationPolicy(.accessory)
        }
        
        (NSApplication.shared.delegate as! AppDelegate).loadPreferences()
    }
}


extension PreferencesViewController: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if (didPreferencesChange()) {
            
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = "Changes not saved"
            alert.informativeText = "Do you want to save the changes?"
            alert.addButton(withTitle: "Cancel")
            alert.addButton(withTitle: "Save")
            alert.addButton(withTitle: "Don't Save")
            
            let modalResponse = alert.runModal()
            if (modalResponse == .alertFirstButtonReturn) {
                return false
            } else if (modalResponse == .alertSecondButtonReturn) {
                self.savePreferences()
                return true
            } else if (modalResponse == .alertThirdButtonReturn) {
                return true
            }
        }
        
        return true
    }
}
