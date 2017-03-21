//
//  PinCodeVCPresenter.swift
//  CoreKPI
//
//  Created by Мануэль on 16.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit

class PinCodeVCPresenter
{
    var pinCodeController: PinCodeViewController!
    var presentedFromBG = false
    let stateMachine = UserStateMachine.shared
    
    var launchController: LaunchViewController {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.launchViewController
    }
    
    var accessGranted = false
    let mainWindow: UIWindow?
    let secondaryWindow: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        return window
    }()
    
    init(in window: UIWindow) {
        
        mainWindow = window
        mainWindow?.windowLevel = 1
    }
    
    func presentPinCodeVC() {
        
        pinCodeController = PinCodeViewController(mode: .logIn)
        pinCodeController.presenter = self
        
        secondaryWindow.isHidden  = false
        secondaryWindow.windowLevel = 2
        secondaryWindow.makeKeyAndVisible()
        secondaryWindow.rootViewController = pinCodeController
        mainWindow?.windowLevel = 1
        mainWindow?.endEditing(true)        
        
        pinCodeController.logOutCompletion = { [weak self] in
            self?.mainWindow?.windowLevel = 1
            self?.mainWindow?.makeKeyAndVisible()
            self?.animateDismissal()
            self?.stateMachine.logOut()
            self?.launchController.dismiss(animated: true, completion: nil)            
        }
        
        pinCodeController.cancelledFromBGCompletion = { [weak self] in
            self?.mainWindow?.windowLevel = 1
            self?.mainWindow?.makeKeyAndVisible()
            self?.animateDismissal()
            self?.launchController.presentStartVC()
        }
        
        pinCodeController.dismissCompletion = { [weak self] in
            self?.mainWindow?.windowLevel = 1
            self?.mainWindow?.makeKeyAndVisible()            
            self?.animateDismissal()
            self?.launchController.presentStartVC()
        }
        
        pinCodeController.successCompletion = { [weak self] in
            self?.mainWindow?.windowLevel = 1
            self?.mainWindow?.makeKeyAndVisible()
            self?.animateDismissal()
            
            if self!.stateMachine.userStateInfo.didEnterBG
            {
                NotificationCenter.default.post(name: .userLoggedIn, object: nil)
            }
            else { self?.stateMachine.checkTokenOnServer() }
        }
    }
    
    private func animateDismissal() {
        
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: { [weak self] in
                        self?.secondaryWindow.alpha = 0
        }) { _ in
            self.secondaryWindow.rootViewController = nil
            self.secondaryWindow.windowLevel = 0
            self.secondaryWindow.alpha = 1.0
        }
    }
}
