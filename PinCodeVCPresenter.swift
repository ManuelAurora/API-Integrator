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
    var pinCodeController: PinCodeViewController = {
        let pinvc = PinCodeViewController(nibName: "PinCodeView", bundle: nil)
        return pinvc
    }()
    
    var launchController: LaunchViewController?
    
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
        
        secondaryWindow.rootViewController = pinCodeController
        secondaryWindow.isHidden  = false
        secondaryWindow.windowLevel = 2
        secondaryWindow.makeKeyAndVisible()
        mainWindow?.windowLevel = 1
        mainWindow?.endEditing(true)
        
        pinCodeController.dismissCompletion = { [weak self] in
            self?.mainWindow?.windowLevel = 1
            self?.mainWindow?.makeKeyAndVisible()
            
            self?.animateDismissal()
        }
        
        _ = pinCodeController.successCompletion = { [weak self] in
            
            self?.launchController?.getModelFromServer()
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
