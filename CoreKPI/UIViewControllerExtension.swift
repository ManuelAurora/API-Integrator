//
//  UIViewControllerExtension.swift
//  CoreKPI
//
//  Created by Семен on 14.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit
import Alamofire



protocol StoryboardInstantiation
{
    typealias optionalClosure = ((TypeOfSelf) -> ())?
    
    associatedtype TypeOfSelf: UIViewController
    
    static func storyboardInstance(_ completion: optionalClosure) -> TypeOfSelf
}

extension StoryboardInstantiation
{
    typealias optionalVcClosure = ((Self) -> ())?
    
    static func storyboardInstance(_ completion: optionalVcClosure = nil) -> Self {
        
        let identifier = String(describing: TypeOfSelf.self)
                
        var sbName = String(describing: TypeOfSelf.self)
        
        if Bundle.main.path(forResource: sbName, ofType: "storyboardc") == nil
        {
            sbName = "Main"
        }
        
        let storyboard = UIStoryboard(name: sbName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier) as! Self
        
        if let completion = completion
        {
            completion(vc)
        }
        
        return vc
    }
}

extension UIViewController
{
    @nonobjc static var spinner: OvalShapeLayer?
    
    func hideKeyboardWhenTappedAround() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
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
        
        let xValue = view.bounds.width / 2
        let yValue = view.bounds.height * 0.8
        let p = CGPoint(x: xValue, y: yValue)
        
        UIViewController.spinner = OvalShapeLayer(point: p, color: color)
        navigationController!.view.layer.addSublayer(UIViewController.spinner!)
    }
    
    func removeWaitingSpinner() {
        
        UserStateMachine.shared.toggleAppFetchingData()
        UIViewController.spinner?.removeFromSuperlayer()
        UIViewController.spinner = nil
    }    
}


