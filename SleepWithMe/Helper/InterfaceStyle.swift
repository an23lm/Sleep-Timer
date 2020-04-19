//
//  InterfaceStyle.swift
//  SleepWithMe
//
//  Created by Anselm Joseph on 19/04/20.
//  Copyright © 2020 an23lm. All rights reserved.
//

import Foundation

enum InterfaceStyle : String {
   case Dark, Light

   init() {
      let type = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
      self = InterfaceStyle(rawValue: type)!
    }
    
    static var current: InterfaceStyle {
        InterfaceStyle()
    }
}
