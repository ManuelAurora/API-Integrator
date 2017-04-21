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
    static let userTappedSecuritySwitch      = Notification.Name("UserTappedSecuritySwitch")
    static let qbManagerRecievedData         = Notification.Name("qbManagerRecievedData")
    static let paypalManagerRecievedData     = Notification.Name("paypalManagerRecievedData")
    static let newExternalKPIadded           = Notification.Name("NewExternalKPIAdded")
    static let modelDidChanged               = Notification.Name("modelDidChange")
    static let userLoggedIn                  = Notification.Name("UserLoggedIn")
    static let userLoggedOut                 = Notification.Name("UserLoggedOut")
    static let userAddedPincode              = Notification.Name("UserAddedPincode")
    static let userRemovedPincode            = Notification.Name("UserRemovedPincode")
    static let userFailedToLogin             = Notification.Name("LoginAttemptFailed")
    static let appDidEnteredBackground       = Notification.Name("AppDidEnteredBackground")
    static let errorDownloadingFile          = Notification.Name("errorDownloadingFile")
    static let googleManagerRecievedData     = Notification.Name("googleManagerRecievedData")
    static let hubspotManagerRecievedData    = Notification.Name("hubspotManagerRecievedData")
    static let salesForceManagerRecievedData = Notification.Name("salesForceManagerRecievedData")
    static let profilePhotoDownloaded        = Notification.Name("ProfilePhotoDownloaded")
}

extension UIStoryboard
{
    enum StoryboardIDs: String
    {
        case mainTabBarController   = "TabBarVC"
        case inviteViewController   = "InviteVC"
        case signInUpViewController = "StartVC"
        case signInViewController   = "SignInVC"
        case pincodeViewController  = "PinCodeViewController"
        case newProfViewController  = "RegistrationCreateProfileVC"
        case registerViewController = "RegisterViewController"
        case onboardViewController  = "OnboardingView"
        case onboardPageVC          = "OnboardingVC"
        case reportViewController   = "ReportAndViewKPI"
        case chartsViewController   = "PageVC"
        case memberViewController   = "MemberInfo"
        case integratedServicesVC   = "SelectIntegratedServices"
        case listOfSuggestedKPIVC   = "ListOfSuggestedKPI"
        case externalKPIVC          = "ConfigureExternal"
        case payPalAuthVC           = "PayPalAuth"
        case webViewController      = "WebViewController"
        case chartTableVC           = "TableViewController"
        case choosePipelineVC       = "hubspotPipelineController"
        case alertSettingsTableVC   = "AddAlert"
    }
    
    func instantiateViewController(withIdentifier: StoryboardIDs) -> UIViewController {
        return instantiateViewController(withIdentifier: withIdentifier.rawValue)
    }
}

struct AnimationConstants
{
    struct Keys
    {
        static let trainingAnimation = "TrainingAnimation"
    }
    
    struct KeyPath
    {
        static let layer = "LayerToRemove"
    }
}

struct UserDefaultsKeys
{
    static let userId = "userId"
    static let pinCode = "PinCode"
    static let token = "token"
    static let pinCodeAttempts = "PinCodeAttempts"
}

struct OurColors
{
    static let violet = UIColor(red: 124.0/255.0, green: 77.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    static let cyan = UIColor(red: 0/255.0, green: 151.0/255.0, blue: 167.0/255.0, alpha: 1.0)
    static let gray = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
    static let blue = UIColor(red: 0/255, green: 185/255, blue: 230/255, alpha: 1.0)
}

public func validate(email: String? = nil, password: String? = nil) -> Bool {
    
    if let email = email
    {
        if email == "" { return false }
        else if email.range(of: "@") == nil ||
            (email.components(separatedBy: "@")[0].isEmpty) ||
            (email.components(separatedBy: "@")[1].isEmpty) { return false }
    }
    
    if let password = password
    {
        if password == "" { return false }
    }
    
    return true
}

public func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
    var i = 0
    return AnyIterator {
        let next = withUnsafePointer(to: &i) {
            $0.withMemoryRebound(to: T.self, capacity: 1) { $0.pointee }
        }
        if next.hashValue != i { return nil }
        i += 1
        return next
    }
}
