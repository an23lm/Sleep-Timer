//
//  PreferencesViewController.swift
//  SleepWithMe
//
//  Created by Ansèlm Joseph on 19/07/18.
//  Copyright © 2018 an23lm. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

    @IBOutlet weak var showDockChecker: NSButton!
    @IBOutlet weak var defaultSleepTimerChecker: NSButton!
    @IBOutlet weak var defaultSleepTimerPicker: NSDatePicker!
    @IBOutlet weak var defaultTimerTextField: NSTextField!
    
    var isShowDockEnabled: Bool! = nil
    var isSleepTimerEnabled: Bool! = nil
    var sleepTime: Date! = nil
    var defaultTimer: Int! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isShowDockEnabled = UserDefaults.standard.bool(forKey: Constants.isDockIconEnabled)
        isSleepTimerEnabled = UserDefaults.standard.bool(forKey: Constants.isSleepTimerEnabled)
        sleepTime = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: Constants.sleepTime))
        defaultTimer = UserDefaults.standard.integer(forKey: Constants.defaultTimer)
        
        showDockChecker.state = isShowDockEnabled ? .on : .off
        defaultSleepTimerChecker.state = isSleepTimerEnabled ? .on : .off
        defaultSleepTimerPicker.dateValue = sleepTime
        defaultTimerTextField.stringValue = String(defaultTimer)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        isShowDockEnabled = getToF(fromState: showDockChecker.state)
        isSleepTimerEnabled = getToF(fromState: defaultSleepTimerChecker.state)
        sleepTime = defaultSleepTimerPicker.dateValue
        
        if defaultTimerTextField.stringValue.trimmingCharacters(in: .whitespaces) == "" {
            defaultTimer = 0
        } else {
            defaultTimer = Int(defaultTimerTextField.stringValue.trimmingCharacters(in: .whitespaces))!
        }
        
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
}
