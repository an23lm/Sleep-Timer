//
//  HotKeyExtension.swift
//  SleepWithMe
//
//  Created by Anselm Joseph on 05/04/21.
//  Copyright © 2021 an23lm. All rights reserved.
//

import AppKit
import HotKey

extension HotKey {
    public convenience init?(keys: String, keyDownHandler: Handler? = nil) {
        guard let keyCombo = KeyCombo(keys: keys) else {
            return nil
        }
        self.init(keyCombo: keyCombo, keyDownHandler: keyDownHandler, keyUpHandler: nil)
    }
}

extension KeyCombo {
    public init?(keys: String) {
        var chosenKey: Key? = nil
        var chosenModifiers: NSEvent.ModifierFlags = []
        for key in keys {
            guard let parsedKey = Key(string: String(key)) else {
                print("Parse fail", key)
                return nil
            }
            
            switch parsedKey {
            case .command: chosenModifiers = chosenModifiers.union(.command)
            case .rightCommand: chosenModifiers = chosenModifiers.union(.command)
            case .option: chosenModifiers = chosenModifiers.union(.option)
            case .rightOption: chosenModifiers = chosenModifiers.union(.option)
            case .control: chosenModifiers = chosenModifiers.union(.control)
            case .rightControl: chosenModifiers = chosenModifiers.union(.control)
            case .shift: chosenModifiers = chosenModifiers.union(.shift)
            case .rightShift: chosenModifiers = chosenModifiers.union(.shift)
            case .function: chosenModifiers = chosenModifiers.union(.function)
            case .capsLock: chosenModifiers = chosenModifiers.union(.capsLock)
            default:
                chosenKey = parsedKey
            }
        }

        if chosenKey == nil {
            return nil
        }
        self.init(carbonKeyCode: chosenKey!.carbonKeyCode, carbonModifiers: chosenModifiers.carbonFlags)
    }
}

