//
//  PreferencesViewController.swift
//  SleepWithMe
//
//  Created by Ansèlm Joseph on 19/07/18.
//  Copyright © 2018 an23lm. All rights reserved.
//

import Cocoa
import Carbon
import HotKey

class PreferencesViewController: NSViewController {

    @IBOutlet weak var autoLaunchChecker: NSButton!
    @IBOutlet weak var showDockChecker: NSButton!
    @IBOutlet weak var defaultSleepTimerChecker: NSButton!
    @IBOutlet weak var defaultSleepTimerPicker: NSDatePicker!
    @IBOutlet weak var defaultTimerTextField: NSTextField!
    @IBOutlet weak var shortcutButton: NSButton!
    
    var isAutoLaunchEnabled: Bool! = nil
    var isShowDockEnabled: Bool! = nil
    var isSleepTimerEnabled: Bool! = nil
    var sleepTime: Date! = nil
    var defaultTimer: Int! = nil
    
    var keyMonitor: Any? = nil
    var flagMonitor: Any? = nil
    
    var isGlobalShortcutListening: Bool {
        get {
            return shortcutButton.isHighlighted
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isAutoLaunchEnabled = UserDefaults.standard.bool(forKey: Constants.autoLaunch)
        isShowDockEnabled = UserDefaults.standard.bool(forKey: Constants.isDockIconEnabled)
        isSleepTimerEnabled = UserDefaults.standard.bool(forKey: Constants.isSleepTimerEnabled)
        sleepTime = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: Constants.sleepTime))
        defaultTimer = UserDefaults.standard.integer(forKey: Constants.defaultTimer)
        
        autoLaunchChecker.state = isAutoLaunchEnabled ? .on : .off
        showDockChecker.state = isShowDockEnabled ? .on : .off
        defaultSleepTimerChecker.state = isSleepTimerEnabled ? .on : .off
        defaultSleepTimerPicker.dateValue = sleepTime
        defaultTimerTextField.stringValue = String(defaultTimer)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        NSApp.activate(ignoringOtherApps: true)
        NSApplication.shared.becomeFirstResponder()
        view.window?.becomeFirstResponder()
        
//        flagMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {
//            guard let locWindow = self.view.window,
//                NSApplication.shared.keyWindow === locWindow else { return $0 }
//
//            self.flagsChanged(with: $0)
//
//            return $0
//        }
        
//        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
//            [weak self] (event) -> NSEvent? in
//
//            guard let here = self else {
//                return event
//            }
//
//            print("hello")
//
//            guard let character = event.characters else {
//                return event
//            }
//
//            return event
//        }
    }
    
    override func flagsChanged(with event: NSEvent) {
        print(event.modifierFlags.intersection(.deviceIndependentFlagsMask))
        
//        switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
//            case [.shift]:
//                print("shift key is pressed")
//            case [.control]:
//                print("control key is pressed")
//            case [.option] :
//                print("option key is pressed")
//            case [.command]:
//                print("Command key is pressed")
//            case [.control, .shift]:
//                print("control-shift keys are pressed")
//            case [.option, .shift]:
//                print("option-shift keys are pressed")
//            case [.command, .shift]:
//                print("command-shift keys are pressed")
//            case [.control, .option]:
//                print("control-option keys are pressed")
//            case [.control, .command]:
//                print("control-command keys are pressed")
//            case [.option, .command]:
//                print("option-command keys are pressed")
//            case [.shift, .control, .option]:
//                print("shift-control-option keys are pressed")
//            case [.shift, .control, .command]:
//                print("shift-control-command keys are pressed")
//            case [.control, .option, .command]:
//                print("control-option-command keys are pressed")
//            case [.shift, .command, .option]:
//                print("shift-command-option keys are pressed")
//            case [.shift, .control, .option, .command]:
//                print("shift-control-option-command keys are pressed")
//            default:
//                print("no modifier keys are pressed")
//        }
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        if (keyMonitor != nil) {
            NSEvent.removeMonitor(keyMonitor!)
        }
        if (flagMonitor != nil) {
            NSEvent.removeMonitor(flagMonitor!)
        }
    }
    
    @IBAction func doneButton(_ sender: Any) {
        isAutoLaunchEnabled = getToF(fromState: autoLaunchChecker.state)
        isShowDockEnabled = getToF(fromState: showDockChecker.state)
        isSleepTimerEnabled = getToF(fromState: defaultSleepTimerChecker.state)
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
        UserDefaults.standard.synchronize()
        
        if (isShowDockEnabled) {
            NSApplication.shared.setActivationPolicy(.regular)
        } else {
            NSApplication.shared.setActivationPolicy(.accessory)
        }
        
        (NSApplication.shared.delegate as! AppDelegate).loadPreferences()
        NSApplication.shared.mainWindow?.close()
    }
    
    private func getToF(fromState state: NSControl.StateValue) -> Bool {
        switch state {
        case .on:
            return true
        case .off:
            return false
        default:
            return false
        }
    }
    
    func updateGlobalShortcut(_ event: NSEvent) {
        if let characters = event.charactersIgnoringModifiers {
            let newGlobalKeybind = GlobalKeybindPreferences.init(
                function: event.modifierFlags.contains(.function),
                control: event.modifierFlags.contains(.control),
                command: event.modifierFlags.contains(.command),
                shift: event.modifierFlags.contains(.shift),
                option: event.modifierFlags.contains(.option),
                capsLock: event.modifierFlags.contains(.capsLock),
                carbonFlags: event.modifierFlags.carbonFlags,
                characters: characters,
                keyCode: UInt32(event.keyCode)
            )
            
            print(newGlobalKeybind.description)
        }
    }
}
