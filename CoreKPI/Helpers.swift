//
//  Helpers.swift
//  CoreKPI
//
//  Created by Мануэль on 27.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit

extension Notification.Name
{
    static let userTappedSecuritySwitch = Notification.Name("UserTappedSecuritySwitch")
}

struct UserDefaultsKeys
{
    static let pinCode = "PinCode"
    static let token = "token"
    static let pinCodeAttempts = "PinCodeAttempts"
}

struct OurColors
{
    static let violet = UIColor(red: 124.0/255.0, green: 77.0/255.0, blue: 255.0/255.0, alpha: 1.0)
}
