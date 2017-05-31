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
    static let hubspotCodeRecieved           = Notification.Name("HubspotCodeRecieved")
    static let hubspotTokenRecieved          = Notification.Name("HubspotTokenRecieved")
    static let reportDataForKpiRecieved      = Notification.Name("ReportDataForKpiRecieved")
    static let addedNewExtKpiOnServer        = Notification.Name("addedNewExternalKpiOnServer")
    static let internetConnectionLost        = Notification.Name("internetConnectionLost")
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
        case questionDetailTableVC  = "QuestionDetailTableViewController"
        case integrationRequestVC   = "SendNewIntegrationViewController"
        case createNewCustomKpi     = "ChooseSuggestedKpi"
        case launchViewController   = "LaunchViewController"
        case teamListViewController = "MemberListTableViewController"
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
    static let lightBlue = UIColor(red: 178/255, green: 234/255, blue: 242/255, alpha: 1.0)
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

public enum Timezones: String
{
    case hawaii   = "Hawaii Time (HST)" //-10
    case alaska   = "Alaska Time (AKST)" //-8
    case pacific  = "Pacific Time (PST)" //-7
    case mountain = "Mountain Time (MST)" //-6
    case central  = "Central Time (CST)" //-5
    case eastern  = "Eastern Time (EST)" //-4
    case error    = "Error"
}

public func timezoneTitleFrom(hoursFromGMT: String) -> Timezones
{
    switch hoursFromGMT
    {
    case "-10": return .hawaii
    case "-8":  return .alaska
    case "-7":  return .pacific
    case "-6":  return .mountain
    case "-5":  return .central
    case "-4":  return .eastern
    default:    return .error
    }
}

public func getKpiNameFrom(id: Int) -> String {
    
    switch id
    {
    case 1: return   "Revenue/new leads"
    case 2:  return  "Key Metrics"
    case 3: return   "Converted leads"
    case 4:  return  "Open opportunities by Stage"
    case 5: return   "Top Sales Rep"
    case 6: return   "New leads by industry"
    case 7:  return  "Campaign ROI"
    case 8:  return  "Net Income"
    case 9:   return "Balance"
    case 10:  return  "Balance by Bank Accounts"
    case 11:  return  "Income/Profit KPIS"
    case 12: return   "Invoices"
    case 13: return   "Non-Paid Invoices"
    case 14: return   "Paid invoices"
    case 15: return   "Paid invoices by Customers"
    case 16: return   "Open invoices by Customers"
    case 17: return   "Overdue Customers"
    case 18: return   "Paid Expenses"
    case 19: return   "Users/Sessions"
    case 20: return    "Audience Overview"
    case 21: return   "Goal Overview"
    case 22: return   "Top Pages by Pageviews"
    case 23:  return  "Top Sources by Sessions"
    case 24:  return  "Top Organic keywords by session"
    case 25:  return   "Top Channels by sessions"
    case 26:  return  "Revenue/ Transactions"
    case 27:  return  "Ecommerce Overview"
    case 28:  return  "Revenue by landing page"
    case 29:  return  "Revenue by Channels"
    case 30:  return  "Top Keywords by Revenue"
    case 31:  return "Top Sources by Revenue"
    case 32:  return  "Deals/Revenue"
    case 33:  return  "Sales Performance"
    case 34:  return   "Sales Funnel"
    case 35:  return  "Deals Closed Won and Lost"
    case 36:  return  "Sales Leaderboard"
    case 37:  return  "Deal Revenue Leaderboard"
    case 38:  return "Closed Deals Leaderboard"
    case 39:  return  "Deal Stage Funnel"
    case 40:  return  "Top Won Deals"
    case 41:  return  "Revenue by Company"
    case 42:  return  "Visits/Contacts"
    case 43:  return  "Marketing Funnel"
    case 44:  return  "Landing Page performance"
    case 45:  return  "Blogging Performance"
    case 46:  return  "E-mail Performance"
    case 47:  return  "Marketing Performance"
    case 48:  return  "Contacts/Visits by Source"
    case 49:  return  "Visits by Source"
    case 50:  return  "Contacts by Referrals"
    case 51:  return  "Top Blog Post by pageviews"
    case 52:  return "Balance"
    case 53:  return "Net Sales/Total Sales"
    case 54:  return "KPIS"
    case 55:  return "Average Revenue sale"
    case 56:  return "Average Revenue sale by period"
    case 57:  return "Top countries by Sales"
    case 58:  return "Top products"
    case 59:  return "Transactions by Status"
    case 60:  return "Pending by Type"
    case 61:  return "Recent Expenses"

    default: return "Error"
        
    }
    
}

//
//1 - SALESFORCE (CRM)
//1    Revenue/new leads
//2    Key Metrics
//3    Converted leads
//4    Open opportunities by Stage
//5    Top Sales Rep
//6    New leads by industry
//7    Campaign ROI
//
//2 - QuickBooks (accounting)
//8    Net Income
//9    Balance
//10    Balance by Bank Accounts
//11    Income/Profit KPIS
//12    Invoices
//13    Non-Paid Invoices
//14    Paid invoices
//15    Paid invoices by Customers
//16    Open invoices by Customers
//17    Overdue Customers
//18    Paid Expenses
//
//3 - Google Analytics (Marketing analytics)
//19    Users/Sessions
//20    Audience Overview
//21    Goal Overview
//22    Top Pages by Pageviews
//23    Top Sources by Sessions
//24    Top Organic keywords by session
//25    Top Channels by sessions
//26    Revenue/ Transactions
//27    Ecommerce Overview
//28    Revenue by landing page
//29    Revenue by Channels
//30    Top Keywords by Revenue
//31    Top Sources by Revenue
//
//4 - Hubspot (CRM)
//32    Deals/Revenue
//33    Sales Performance
//34    Sales Funnel
//35    Deals Closed Won and Lost
//36    Sales Leaderboard
//37    Deal Revenue Leaderboard
//38    Closed Deals Leaderboard
//39    Deal Stage Funnel
//40    Top Won Deals
//41    Revenue by Company
//42    Visits/Contacts
//43    Marketing Funnel
//44    Landing Page performance
//45    Blogging Performance
//46    E-mail Performance
//47    Marketing Performance
//48    Contacts/Visits by Source
//49    Visits by Source
//50    Contacts by Referrals
//51    Top Blog Post by pageviews
//
//6 - Paypal
//52    Balance
//53    Net Sales/Total Sales
//54    KPIS
//55    Average Revenue sale
//56    Average Revenue sale by…
//57    Top countries by Sales
//58    Top products
//59    Transactions by Status
//60    Pending by Type
//61    Recent Expenses
