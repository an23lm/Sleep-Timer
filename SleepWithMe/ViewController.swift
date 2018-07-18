//
//  ViewController.swift
//  SleepWithMe
//
//  Created by Ansèlm Joseph on 05/06/18.
//  Copyright © 2018 an23lm. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var timerView: NSTimerView!
    @IBOutlet weak var timerLabel: NSTextField!
    @IBOutlet weak var minuteTitleLabel: NSTextField!
    
    @IBOutlet weak var decreaseTimeButton: NSTimerButton!
    @IBOutlet weak var increaseTimeButton: NSTimerButton!
    
    @IBOutlet weak var activationButton: NSButton!
    
    @IBOutlet weak var closeButton: NSTimerButton!
    @IBOutlet weak var preferencesButton: NSButton!
    
    private var timer: Timer? = nil
    
    private var currentMinutes: Int = 0 {
        didSet {
            timerLabel.stringValue = String(currentMinutes)
            if isTimerRunning {
                (NSApplication.shared.delegate as! AppDelegate).setMenuBarTitle(String(currentMinutes))
                if !isRestartingTimer {
                    if currentMinutes == 5 {
                        sendNotification()
                    }
                }
            } else {
                (NSApplication.shared.delegate as! AppDelegate).setMenuBarTitle("")
            }
        }
    }
    
    private var isTimerRunning: Bool = false
    private var isRestartingTimer: Bool = false
    private var stepSize: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        self.view.wantsLayer = true
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .center
        
        activationButton.wantsLayer = true
        setStartTimerButton()
        activationButton.isBordered = false
        activationButton.layer?.cornerRadius = 5
        
        decreaseTimeButton.style = .decrement
        decreaseTimeButton.wantsLayer = true
        decreaseTimeButton.isBordered = false
        if #available(OSX 10.12, *) {
            decreaseTimeButton.layer?.backgroundColor = NSColor(displayP3Red: 0, green: 105/256.0, blue: 91/256.0, alpha: 1).cgColor
        } else {
            decreaseTimeButton.layer?.backgroundColor = NSColor(deviceRed: 0, green: 105/256.0, blue: 91/256.0, alpha: 1).cgColor
        }
        decreaseTimeButton.layer?.cornerRadius = 25
        
        increaseTimeButton.style = .increment
        increaseTimeButton.wantsLayer = true
        increaseTimeButton.isBordered = false
        if #available(OSX 10.12, *) {
            increaseTimeButton.layer?.backgroundColor = NSColor(displayP3Red: 0, green: 105/256.0, blue: 91/256.0, alpha: 1).cgColor
        } else {
            increaseTimeButton.layer?.backgroundColor = NSColor(deviceRed: 0, green: 105/256.0, blue: 91/256.0, alpha: 1).cgColor
        }
        increaseTimeButton.layer?.cornerRadius = 25
        
        closeButton.style = .close
        closeButton.wantsLayer = true
        closeButton.isBordered = false
        if #available(OSX 10.12, *) {
            closeButton.layer?.backgroundColor = NSColor(displayP3Red: 237/256.0, green: 108/256.0, blue: 97/256.0, alpha: 1).cgColor
        } else {
            closeButton.layer?.backgroundColor = NSColor(deviceRed: 237/256.0, green: 108/256.0, blue: 97/256.0, alpha: 1).cgColor
        }
        closeButton.layer?.cornerRadius = 10
        
        preferencesButton.wantsLayer = true
        preferencesButton.isBordered = false
        preferencesButton.layer?.backgroundColor = NSColor(calibratedWhite: 1, alpha: 0).cgColor
    }
    
    override func viewDidAppear() {
        timerLabel.stringValue = String(currentMinutes)
        timerView.animateBackgroundArc(duration: 1.0)
        timerView.animateForegroundArc(toPosition: CGFloat(self.currentMinutes) * self.stepSize, fromPosition: 0, duration: 1.0)
    }
    
    @IBAction func exit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func onClickPreferencesButton(_ sender: Any) {
        (NSApplication.shared.delegate as! AppDelegate).closePopover(sender)
        let storyboard = NSStoryboard.init(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let prefWindowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "PreferencesController")) as! NSWindowController
        prefWindowController.showWindow(self)
    }
    
    @IBAction func decreaseTimer(_ sender: Any) {
        if currentMinutes > 1 {
            currentMinutes -= 1
        }
    }
    
    @IBAction func increaseTimer(_ sender: Any) {
        currentMinutes += 1
        if !isRestartingTimer {
            isRestartingTimer = true
            timerView.animateForegroundArc(duration: 1.0)
            if #available(OSX 10.12, *) {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
                    self.isRestartingTimer = false
                    if self.isTimerRunning {
                        self.restartTimer()
                    }
                }
            } else {
                Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(increaseTimerScheduledTimer(_:)), userInfo: nil, repeats: false)
            }
        }
    }
    
    @objc func increaseTimerScheduledTimer(_ timer: Any) {
        self.isRestartingTimer = false
        if self.isTimerRunning {
            self.restartTimer()
        }
    }
    
    private func setStopTimerButton() {
        isTimerRunning = true
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .center
        self.activationButton.attributedTitle = NSAttributedString(string: "Stop Timer", attributes: [NSAttributedStringKey.foregroundColor: NSColor.white, NSAttributedStringKey.paragraphStyle: pstyle, NSAttributedStringKey.font: NSFont.systemFont(ofSize: 20, weight: .light)])
        if #available(OSX 10.12, *) {
            self.activationButton.layer?.backgroundColor = NSColor(displayP3Red: 238/256.0, green: 96/256.0, blue: 2/256.0, alpha: 1.0).cgColor
        } else {
            self.activationButton.layer?.backgroundColor = NSColor(deviceRed: 238/256.0, green: 96/256.0, blue: 2/256.0, alpha: 1.0).cgColor
        }
    }
    
    private func setStartTimerButton() {
        isTimerRunning = false
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .center
        self.activationButton.attributedTitle = NSAttributedString(string: "Start Timer", attributes: [NSAttributedStringKey.foregroundColor: NSColor.white, NSAttributedStringKey.paragraphStyle: pstyle, NSAttributedStringKey.font: NSFont.systemFont(ofSize: 20, weight: .regular)])
        if #available(OSX 10.12, *) {
            self.activationButton.layer?.backgroundColor = NSColor(displayP3Red: 83/256.0, green: 0/256.0, blue: 232/256.0, alpha: 1.0).cgColor
        } else {
            self.activationButton.layer?.backgroundColor = NSColor(deviceRed: 83/256.0, green: 0/256.0, blue: 232/256.0, alpha: 1.0).cgColor
        }
    }
    
    @IBAction func activateTimer(_ sender: Any) {
        if timer == nil {
            self.setStopTimerButton()
            self.stepSize = 1.0/CGFloat(self.currentMinutes)
            (NSApplication.shared.delegate as! AppDelegate).setMenuBarTitle(String(currentMinutes))
            if #available(OSX 10.12, *) {
                timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { (timer) in
                    self.currentMinutes -= 1
                    if !self.isRestartingTimer {
                        self.timerView.animateForegroundArc(toPosition: CGFloat(self.currentMinutes) * self.stepSize, duration: 1.0)
                    }
                    if self.currentMinutes == 0 {
                        timer.invalidate()
                        (NSApplication.shared.delegate as! AppDelegate).setMenuBarTitle("")
                        self.timer = nil
                        self.setStartTimerButton()
                        self.sush()
                    }
                }
            } else {
                timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(activateTimerScheduledTimer(_:)), userInfo: nil, repeats: true)
            }
            if !self.isRestartingTimer {
                self.timerView.animateForegroundArc(duration: 1.0)
            }
        } else {
            stopTimer()
        }
    }
    
    @objc func activateTimerScheduledTimer(_ timer: Timer) {
        self.currentMinutes -= 1
        if !self.isRestartingTimer {
            self.timerView.animateForegroundArc(toPosition: CGFloat(self.currentMinutes) * self.stepSize, duration: 1.0)
        }
        if self.currentMinutes == 0 {
            timer.invalidate()
            (NSApplication.shared.delegate as! AppDelegate).setMenuBarTitle("")
            self.timer = nil
            self.setStartTimerButton()
            self.sush()
        }
    }
    
    func stopTimer() {
        (NSApplication.shared.delegate as! AppDelegate).setMenuBarTitle("")
        setStartTimerButton()
        timer?.invalidate()
        timer = nil
    }
    
    func sendNotification() {
        let notif = NSUserNotification()
        notif.title = "\(currentMinutes) mins to zzz"
        notif.informativeText = "SleepWithMe will put your Mac to sleep with you in \(currentMinutes) mins."
        notif.soundName = nil
        notif.hasActionButton = true
        notif.actionButtonTitle = "Stop Timer"
        
        let center = NSUserNotificationCenter.default
        center.deliver(notif)
    }
    
    func restartTimer() {
        timer?.invalidate()
        timer = nil
        if !isRestartingTimer {
            activateTimer(self)
        }
    }
    
    func sush() {
        let putMeToSleep = PutMeToSleep.getObject() as! AppleScriptProtocol
        putMeToSleep.sush()
    }
}
