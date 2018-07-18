//
//  SleepTimer.swift
//  SleepWithMe
//
//  Created by Ansèlm Joseph on 19/07/18.
//  Copyright © 2018 an23lm. All rights reserved.
//

import Foundation

internal class SleepTimer {
    let shared = SleepTimer()
    
    var timer: Timer? = nil
    
    var currentMinutes: Int = 0 {
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
    
    var isTimerRunning: Bool = false
    var isRestartingTimer: Bool = false
    var stepSize: CGFloat = 0
}
