//
//  SegueManager.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 02.05.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit

enum SegueManager: String
{
    case mainTabBarVC          = "TabBarVC"
    case inviteVC              = "InviteVC"
    case signInUpVC            = "StartVC"
    case signInVC              = "SignInVC"
    case pincodeVC             = "PinCodeViewController"
    case newProfVC             = "RegistrationCreateProfileVC"
    case registerVC            = "RegisterViewController"
    case onboardVC             = "OnboardingView"
    case onboardPageVC         = "OnboardingVC"
    case reportVC              = "ReportAndViewKPI"
    case chartsVC              = "PageVC"
    case memberVC              = "MemberInfo"
    case intServicesVC         = "SelectIntegratedServices"
    case suggestedKPIVC        = "ListOfSuggestedKPI"
    case externalKPIVC         = "ConfigureExternal"
    case payPalAuthVC          = "PayPalAuth"
    case webVC                 = "WebViewController"
    case chartTableVC          = "TableViewController"
    case choosePipelineVC      = "hubspotPipelineController"
    case alertSettingsTableVC  = "AddAlert"
    case questionDetailTableVC = "QuestionDetailTableViewController"
    case integrationRequestVC  = "SendNewIntegrationViewController"
    
    private var storyboard: UIStoryboard {
        return UIStoryboard.init(name: "Main", bundle: nil)
    }
    
    func getClassName() -> UIViewController.Type {
        
        switch self
        {
        case .mainTabBarVC: return MainTabBarViewController.self
        case .inviteVC: return InviteTableViewController.self
        case .signInUpVC: return SignInUpViewController.self
        case .signInVC: return SignInViewController.self
        case .pincodeVC: return PinCodeViewController.self
        case .newProfVC: return NewProfileTableViewController.self
        case .registerVC: return RegisterViewController.self
        case .onboardVC: return OnboardingViewController.self
        case .onboardPageVC: return OnboardingPageViewController.self
        case .reportVC: return ReportAndViewKPITableViewController.self
        case .chartsVC: return ChartsPageViewController.self
        case .memberVC: return MemberInfoViewController.self
        case .intServicesVC: return SelectIntegratedServicesViewController.self
        case .suggestedKPIVC: return ChooseSuggestedKPITableViewController.self
        case .externalKPIVC: return ExternalKPIViewController.self
        case .payPalAuthVC: return PayPalAuthViewController.self
        case .webVC: return WebViewController.self
        case .chartTableVC: return TableViewChartController.self
        case .choosePipelineVC: return HubspotChoosePipelineViewController.self
        case .questionDetailTableVC: return QuestionDetailTableViewController.self
        case .integrationRequestVC: return SendNewIntegrationViewController.self
        case .alertSettingsTableVC: return AlertSettingsTableViewController.self
        
        }
    }
    
    func getRef() {
        
        let id = self.rawValue
        let vc = storyboard.instantiateViewController(withIdentifier: id)
        
        
        
  
    }
    
    
    
}
