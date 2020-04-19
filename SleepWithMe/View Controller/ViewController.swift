//
//  ViewController.swift
//  SleepWithMe
//
//  Created by Ansèlm Joseph on 05/06/18.
//  Copyright © 2018 an23lm. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    // MARK: - Public Variables
    var isPopover: Bool = false
    
    // MARK: - Private Variables
    private lazy var preferencesMenu: NSMenu = {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(onClickPreferencesMenuItem(_:)), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Sleep With Me", action: #selector(exit(_:)), keyEquivalent: "q"))
        
        return menu
    }()
    private var isFirstNumberEntry = false
    private var keyMonitor: Any?
    
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var timerView: NSTimerView!
    @IBOutlet weak var timerLabel: NSTextField!
    @IBOutlet weak var minuteTitleLabel: NSTextField!
    @IBOutlet weak var decreaseTimeButton: NSTimerButton!
    @IBOutlet weak var increaseTimeButton: NSTimerButton!
    @IBOutlet weak var activationButton: NSButton!
    @IBOutlet weak var preferencesButton: NSButton!
    
    //MARK: - Computed Properties
    private var currentMinutes: Int {
       return SleepTimer.shared.currentMinutes
    }
    
    private var isTimerRunning: Bool {
        return SleepTimer.shared.isTimerRunning
    }

    private var stepSize: CGFloat {
        return SleepTimer.shared.stepSize
    }
    
    //MARK: - Override methords
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        SleepTimer.shared.onTimeRemainingChange(onTimeRemainingChange)
        SleepTimer.shared.onTimerActivated(onTimerActivated)
        SleepTimer.shared.onTimerInvalidated(onTimerInvalidated)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        NSApp.activate(ignoringOtherApps: true)
        NSApplication.shared.becomeFirstResponder()
        self.view.window?.isMovableByWindowBackground = !self.isPopover
        
        isFirstNumberEntry = true
        
        if SleepTimer.shared.isTimerRunning {
            setStopTimerButton()
        } else {
            setStartTimerButton()
        }
        
        self.view.becomeFirstResponder()
        
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            [weak self] (event) -> NSEvent? in
            
            guard let here = self else {
                return event
            }
            
            guard let character = event.characters else {
                return event
            }
            
            if let number = Int(character) {
                if (here.isFirstNumberEntry) {
                    here.isFirstNumberEntry = false
                    SleepTimer.shared.set(minutes: number)
                } else {
                    let minutes = (SleepTimer.shared.currentMinutes * 10) + number
                    SleepTimer.shared.set(minutes: minutes)
                }
            } else if let keyCode = event.specialKey {
                if keyCode == .backspace || keyCode == .delete {
                    let minutes = (SleepTimer.shared.currentMinutes / 10)
                    SleepTimer.shared.set(minutes: minutes)
                } else if keyCode == .enter || keyCode == .carriageReturn {
                    SleepTimer.shared.startTimer()
                }
            }

            return event
        }
    }
    
    override func viewWillDisappear() {
        if (keyMonitor != nil) {
            NSEvent.removeMonitor(keyMonitor!)
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func viewDidAppear() {
        timerLabel.stringValue = String(currentMinutes)
        timerView.animateBackgroundArc(duration: 0.5)
        if (SleepTimer.shared.isTimerRunning) {
            timerView.animateForegroundArc(toPosition: CGFloat(self.currentMinutes) * self.stepSize, fromPosition: 0, duration: 1.0)
        } else {
            timerView.animateForegroundArc(toPosition: CGFloat(SleepTimer.shared.currentMinutes) * self.stepSize, fromPosition: 0, duration: 1.0)
        }
    }
    
    //MARK: - Private Methods
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
        
        preferencesButton.wantsLayer = true
        preferencesButton.isBordered = false
        preferencesButton.layer?.backgroundColor = NSColor(calibratedWhite: 1, alpha: 0).cgColor
        
        if !isPopover {
            preferencesButton.isHidden = true
        }
    }
    
    private func setStopTimerButton() {
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .center
        self.activationButton.attributedTitle = NSAttributedString(string: "Stop Timer", attributes: [NSAttributedString.Key.foregroundColor: NSColor.white, NSAttributedString.Key.paragraphStyle: pstyle, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 20, weight: .light)])
        if #available(OSX 10.12, *) {
            self.activationButton.layer?.backgroundColor = NSColor(displayP3Red: 238/256.0, green: 96/256.0, blue: 2/256.0, alpha: 1.0).cgColor
        } else {
            self.activationButton.layer?.backgroundColor = NSColor(deviceRed: 238/256.0, green: 96/256.0, blue: 2/256.0, alpha: 1.0).cgColor
        }
    }
    
    private func setStartTimerButton() {
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .center
        self.activationButton.attributedTitle = NSAttributedString(string: "Start Timer", attributes: [NSAttributedString.Key.foregroundColor: NSColor.white, NSAttributedString.Key.paragraphStyle: pstyle, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 20, weight: .regular)])
        if #available(OSX 10.12, *) {
            self.activationButton.layer?.backgroundColor = NSColor(displayP3Red: 83/256.0, green: 0/256.0, blue: 232/256.0, alpha: 1.0).cgColor
        } else {
            self.activationButton.layer?.backgroundColor = NSColor(deviceRed: 83/256.0, green: 0/256.0, blue: 232/256.0, alpha: 1.0).cgColor
        }
    }
    
    //MARK: - Callback Closures
    lazy var onTimeRemainingChange: SleepTimer.onTimeRemainingCallback = {[weak self] (minutes) in
        self?.timerLabel.stringValue = String(minutes)
        if (SleepTimer.shared.isTimerRunning) {
            self?.timerView.moveForegorundArc(toPosition: CGFloat(minutes) * SleepTimer.shared.stepSize)
        }
    }
    
    lazy var onTimerActivated: SleepTimer.onTimerActivatedCallback = {[weak self] in
        self?.setStopTimerButton()
        self?.timerView.moveForegorundArc(toPosition: 1.0)
    }
    
    lazy var onTimerInvalidated: SleepTimer.onTimerInvalidatedCallback = {[weak self] (_) in
        self?.setStartTimerButton()
        self?.timerView.moveForegorundArc(toPosition: 1.0)
    }
    
    //MARK: - Actions
    @objc func exit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func onClickPreferencesMenuButton(_ sender: Any) {
        let button = sender as! NSButton
        let point = button.frame.origin
        
        preferencesMenu.popUp(positioning: nil, at: point, in: self.view)
    }
    
    @objc func onClickPreferencesMenuItem(_ sender: Any) {
        (NSApplication.shared.delegate as! AppDelegate).closePopover(sender)
        performSegue(withIdentifier: "ShowPreferences", sender: self)
    }
    
    @IBAction func decreaseTimer(_ sender: Any) {
        SleepTimer.shared.decreaseTime()
    }
    
    @IBAction func increaseTimer(_ sender: Any) {
        SleepTimer.shared.increaseTime()
    }
    
    @IBAction func timerToggleButton(_ sender: Any) {
        SleepTimer.shared.toggleTimer()
    }
}
