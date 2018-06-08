//
//  PutMeToSleep.swift
//  SleepWithMe
//
//  Created by Ansèlm Joseph on 05/06/18.
//  Copyright © 2018 an23lm. All rights reserved.
//

import Foundation
import AppleScriptObjC

class PutMeToSleep {
    static func load() {
        Bundle.main.loadAppleScriptObjectiveCScripts()
    }
    static func getObject() -> AnyObject {
    
        guard let scriptObj = NSClassFromString("PutMeToSleep") else {
            assertionFailure()
            fatalError()
        }
        
        let obj = scriptObj.alloc()
        return obj as AnyObject
    }
}
