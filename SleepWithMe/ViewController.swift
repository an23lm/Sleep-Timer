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
    
    @IBOutlet weak var decreaseTimeButton: NSButton!
    @IBOutlet weak var increaseTimeButton: NSButton!
    
    @IBOutlet weak var activationButton: NSButton!
    
    @IBOutlet weak var closeButton: NSButton!
    
    private var timer: Timer? = nil
    
    private var currentMinutes: Int = 0 {
        didSet {
            timerLabel.stringValue = String(currentMinutes)
        }
    }
    
    private var stepSize: CGFloat = 0
    
    let greenColor = CGColor(red: 0, green: 0.7, blue: 0, alpha: 0.6)
    let redColor = CGColor(red: 0.7, green: 0, blue: 0, alpha: 0.6)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.wantsLayer = true
        activationButton.title = "Start Timer"
        activationButton.wantsLayer = true
        activationButton.isBordered = false
        activationButton.layer?.backgroundColor = greenColor
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewDidAppear() {
        timerLabel.stringValue = String(currentMinutes)
        timerView.animateBackgroundArc(duration: 1.0)
        timerView.animateForegroundArc(toPosition: CGFloat(self.currentMinutes) * self.stepSize, fromPosition: 0, duration: 1.0)
    }
    
    @IBAction func exit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func decreaseTimer(_ sender: Any) {
        if currentMinutes > 1 {
            currentMinutes -= 1
        }
    }
    
    @IBAction func increaseTimer(_ sender: Any) {
        currentMinutes += 1
    }
    
    @IBAction func activateTimer(_ sender: Any) {
        if timer == nil {
            stepSize = 1.0/CGFloat(currentMinutes)
            activationButton.title = "Stop Timer"
            self.activationButton.layer?.backgroundColor = self.redColor
            timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (timer) in
                self.currentMinutes -= 1
                self.timerView.animateForegroundArc(toPosition: CGFloat(self.currentMinutes) * self.stepSize, duration: 1.0)
                if self.currentMinutes == 0 {
                    print("Timer done")
                    timer.invalidate()
                    self.timer = nil
                    self.activationButton.title = "Start Timer"
                    self.activationButton.layer?.backgroundColor = self.greenColor
                    self.appleScript()
                }
            }
            currentMinutes += 1
            timer?.fire()
        } else {
            activationButton.title = "Start Timer"
            self.activationButton.layer?.backgroundColor = self.greenColor
            timer?.invalidate()
            timer = nil
        }
    }
    
    func appleScript() {
        let path = Bundle.main.bundleURL
        print(path)
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["./SleepWithMe/SleepScript.scpt"]
        
        task.launch()
//        let appleScript: NSAppleScript = NSAppleScript(source:
//            """
//            tell application \"System Events\"
//                sleep
//            end tell
//            """)!
//        let err: AutoreleasingUnsafeMutablePointer<NSDictionary?>? = nil
//        appleScript.executeAndReturnError(err)
//        print(err?.pointee)
    }
}

