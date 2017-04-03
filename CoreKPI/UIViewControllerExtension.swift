//
//  UIViewControllerExtension.swift
//  CoreKPI
//
//  Created by Семен on 14.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    private static var spinner: OvalShapeLayer?
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showAlert(title: String, errorMessage: String) {
        
        let alertController = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addWaitingSpinner(at point: CGPoint, color: UIColor) {
        
        guard UIViewController.spinner == nil else { return }
        
        UserStateMachine.shared.toggleAppFetchingData()
        
        UIViewController.spinner = OvalShapeLayer(point: point, color: color)
        //UIViewController.spinner?.frame.origin.y -= 80 //Temporary hardcoded
        view.layer.addSublayer(UIViewController.spinner!)
    }
    
    func removeWaitingSpinner() {
        
        UserStateMachine.shared.toggleAppFetchingData()        
        UIViewController.spinner?.removeFromSuperlayer()
        UIViewController.spinner = nil
    }
}

