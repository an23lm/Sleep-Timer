//
//  SleepTimer.swift
//  SleepWithMe
//
//  Created by Ansèlm Joseph on 19/07/18.
//  Copyright © 2018 an23lm. All rights reserved.
//

import Foundation


internal class SleepTimer {
    //MARK: - Shared properties
    static weak var shared: SleepTimer! = nil
    
    //MARK: - Private properties
    private var timer: Timer? = nil
    private var onTimeRemainingCallbacks: [onTimeRemainingCallback?] = []
    private var onTimerActivatedCallbacks: [onTimerActivatedCallback?] = []
    private var onTimerInvalidatedCallbacks: [onTimerInvalidatedCallback?] = []
    
    //MARK: - Internal properties
    internal var currentMinutes: Int = 0 {
        didSet {
            if currentMinutes == 0 {
                currentMinutes = 1
            }
            notifyTimeRemainingChange()
        }
    }
    internal var isTimerRunning: Bool = false
    internal var stepSize: CGFloat = 0
    
    //MARK: - Typealiases
    typealias onTimeRemainingCallback = (_ minutes: Int) -> ()
    typealias onTimerActivatedCallback = () -> ()
    typealias onTimerInvalidatedCallback = (_ didComplete: Bool) -> ()
    
    //MARK: - Register callbacks
    internal func onTimeRemainingChange(_ callback: @escaping onTimeRemainingCallback) {
        onTimeRemainingCallbacks.append(callback)
    }
    internal func onTimerActivated(_ callback: @escaping onTimerActivatedCallback) {
        onTimerActivatedCallbacks.append(callback)
    }
    internal func onTimerInvalidated(_ callback: @escaping onTimerInvalidatedCallback) {
        onTimerInvalidatedCallbacks.append(callback)
    }
    
    //MARK: - Notify callbacks
    private func notifyTimeRemainingChange() {
        for callback in onTimeRemainingCallbacks {
            callback?(currentMinutes)
        }
    }
    private func notifyTimerActivated() {
        for callback in onTimerActivatedCallbacks {
            callback?()
        }
    }
    private func notifyTimerInvalidated(didComplete: Bool) {
        for callback in onTimerInvalidatedCallbacks {
            callback?(didComplete)
        }
    }
    
    //MARK: Timer methods
    internal func toggleTimer() {
        if timer == nil {
            startTimer()
        } else {
            stopTimer(didComplete: false)
        }
    }
    
    internal func set(minutes: Int) {
        currentMinutes = minutes
        stepSize = 1.0/CGFloat(currentMinutes)
    }
    
    internal func increaseTime() {
        currentMinutes += 1
        stepSize = 1.0/CGFloat(currentMinutes)
    }
    
    internal func decreaseTime() {
        if currentMinutes > 1 {
            currentMinutes -= 1
        }
    }
    
    internal func startTimer() {
        if #available(OSX 10.12, *) {
            timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { (timer) in
                self.timerFired(timer)
            }
        } else {
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(timerFired(_:)), userInfo: nil, repeats: true)
        }
        isTimerRunning = true
        notifyTimerActivated()
    }
    
    @objc private func timerFired(_ timer: Timer) {
        if self.currentMinutes <= 1 {
            stopTimer(didComplete: true)
            return
        }
        self.currentMinutes -= 1
    }
    
    internal func stopTimer(didComplete: Bool) {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        notifyTimerInvalidated(didComplete: didComplete)
    }
}
