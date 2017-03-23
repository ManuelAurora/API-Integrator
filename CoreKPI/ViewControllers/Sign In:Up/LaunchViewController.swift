//
//  LaunchViewController.swift
//  CoreKPI
//
//  Created by Семен on 23.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    let userStateMachine = UserStateMachine.shared
    
    lazy var appDelegate: AppDelegate = {
        return UIApplication.shared.delegate as! AppDelegate
    }()
    
    lazy var mainTabBar: MainTabBarViewController = {
        let mtbvc = self.storyboard?.instantiateViewController(withIdentifier: .mainTabBarController) as! MainTabBarViewController
        mtbvc.appDelegate = self.appDelegate
        mtbvc.model = self.userStateMachine.model
        
        return mtbvc
    }()
    
    lazy var signInUpViewController: SignInUpViewController = {
        
        let siuvc = self.storyboard?.instantiateViewController(withIdentifier: .signInUpViewController) as! SignInUpViewController
        siuvc.launchController = self
        siuvc.model = self.userStateMachine.model
        return siuvc
    }()
    
    lazy var signInViewController: SignInViewController = {
        let sivc = self.storyboard?.instantiateViewController(withIdentifier: .signInViewController) as! SignInViewController
        
        return sivc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.launchViewController = self
        
        if UserDefaults.standard.object(forKey: UserDefaultsKeys.pinCode) != nil {
            userStateMachine.userStateInfo.usesPinCode = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        subscribeToNotifications()
        userStateMachine.prepareToLogin()
        
        if userStateMachine.userStateInfo.haveLocalToken
        {
            if userStateMachine.userStateInfo.usesPinCode && !userStateMachine.userStateInfo.didEnterBG
            {
                tryLoginByPinCode()
            }
            else if !userStateMachine.userStateInfo.usesPinCode
            {
                userStateMachine.checkTokenOnServer()
            }
            else { presentStartVC() }
        }
        else { presentStartVC() }
    }
    
    private func subscribeToNotifications() {
        
        let nc = NotificationCenter.default
        
        nc.addObserver(self, selector: #selector(LaunchViewController.showTabBarVC), name: .userLoggedIn, object: nil)
        nc.addObserver(self,
                       selector: #selector(LaunchViewController.presentStartVC),
                       name: .userLoggedOut,
                       object: nil)
    }
    
    func tryLoginByPinCode() {
                
        appDelegate.pinCodeVCPresenter.presentedFromBG = false
        appDelegate.pinCodeVCPresenter.presentPinCodeVC()
    }
    
    func showTabBarVC() {
        mainTabBar.applyInitialSettings()
        show(mainTabBar)
        appDelegate.loggedIn = true
        mainTabBar.selectedIndex = 0
        userStateMachine.makeLoaded()
        
        //This will be executed, when user return from BG and left chosen profile opened
        if mainTabBar.teamListNavController.viewControllers.count >= 2,
            let memberInfoVC = mainTabBar.teamListNavController.viewControllers[1] as? MemberInfoViewController
        {
            memberInfoVC.tableView.reloadData()
        }
    }
    
    func presentStartVC() {
        
        show(signInUpViewController)
        
        mainTabBar.teamListNavController.popToRootViewController(animated: false)
        mainTabBar.alertsNavController.popToRootViewController(animated: false)
        mainTabBar.supportNavController.popToRootViewController(animated: false)
        mainTabBar.dashboardNavController.popToRootViewController(animated: false)
        
        guard let signInViewController = signInUpViewController.signInViewController else { return }
        
        signInViewController.clearTextFields()
        signInViewController.toggleEnterByKeyButton(isEnabled: appDelegate.pinCodeAttempts > 0)
    }
    
    private func show(_ viewController: UIViewController) {
        
        let animated = userStateMachine.userStateInfo.wasLoaded
        
        if animated
        {
            UIView.transition(with: appDelegate.window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.setRoot(viewController)
            }, completion: nil)
        }
        else { setRoot(viewController) }
    }
    
    private func setRoot(_ viewController: UIViewController) {
        
        self.appDelegate.window?.rootViewController = viewController
    }
}
