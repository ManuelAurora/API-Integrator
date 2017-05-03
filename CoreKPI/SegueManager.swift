//
//  SegueManager.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 02.05.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

//import Foundation
//import UIKit
//
//enum SegueManager: String
//{
//    case mainTabBarVC          = "TabBarVC"
//    case inviteVC              = "InviteVC"
//    case signInUpVC            = "StartVC"
//    case signInVC              = "SignInVC"
//    case pincodeVC             = "PinCodeViewController"
//    case newProfVC             = "RegistrationCreateProfileVC"
//    case registerVC            = "RegisterViewController"
//    case onboardVC             = "OnboardingView"
//    case onboardPageVC         = "OnboardingVC"
//    case reportVC              = "ReportAndViewKPI"
//    case chartsVC              = "PageVC"
//    case memberVC              = "MemberInfo"
//    case intServicesVC         = "SelectIntegratedServices"
//    case suggestedKPIVC        = "ListOfSuggestedKPI"
//    case externalKPIVC         = "ConfigureExternal"
//    case payPalAuthVC          = "PayPalAuth"
//    case webVC                 = "WebViewController"
//    case chartTableVC          = "TableViewController"
//    case choosePipelineVC      = "hubspotPipelineController"
//    case alertSettingsTableVC  = "AddAlert"
//    case questionDetailTableVC = "QuestionDetailTableViewController"
//    case integrationRequestVC  = "SendNewIntegrationViewController"
//    
//    private var storyboard: UIStoryboard {
//        return UIStoryboard.init(name: "Main", bundle: nil)
//    }
//    
//    func getClassName<T>() -> T {
//        
//        switch self
//        {
//        case .mainTabBarVC: return MainTabBarViewController.self as! T
//        case .inviteVC: return InviteTableViewController.self as! T
//        case .signInUpVC: return SignInUpViewController.self as! T
//        case .signInVC: return SignInViewController.self as! T
//        case .pincodeVC: return PinCodeViewController.self as! T
//        case .newProfVC: return NewProfileTableViewController.self as! T
//        case .registerVC: return RegisterViewController.self as! T
//        case .onboardVC: return OnboardingViewController.self as! T
//        case .onboardPageVC: return OnboardingPageViewController.self as! T
//        case .reportVC: return ReportAndViewKPITableViewController.self as! T
//        case .chartsVC: return ChartsPageViewController.self as! T
//        case .memberVC: return MemberInfoViewController.self as! T
//        case .intServicesVC: return SelectIntegratedServicesViewController.self as! T
//        case .suggestedKPIVC: return ChooseSuggestedKPITableViewController.self as! T
//        case .externalKPIVC: return ExternalKPIViewController.self as! T
//        case .payPalAuthVC: return PayPalAuthViewController.self as! T
//        case .webVC: return WebViewController.self as! T
//        case .chartTableVC: return TableViewChartController.self as! T
//        case .choosePipelineVC: return HubspotChoosePipelineViewController.self as! T
//        case .questionDetailTableVC: return QuestionDetailTableViewController.self as! T
//        case .integrationRequestVC: return SendNewIntegrationViewController.self as! T
//        case .alertSettingsTableVC: return AlertSettingsTableViewController.self as! T
//        }
//    }
//    
//    func instantiate<T>() -> T where T: UIViewController {
//        
//        let storyboardID = T.restorationIdentifier
//        let vc = storyboard.instantiateViewController(withIdentifier: storyboardID)
//       // vc.restorationIdentifier
//        let className:T = getClassName().self()
//        return vc as! className
//    }
//      
//}
