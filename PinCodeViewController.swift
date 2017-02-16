//
//  PinCodeViewController.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 15.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class PinCodeViewController: UIViewController
{
    fileprivate let pincodeLock = PinCodeLock()
    
    private var isAnimationCompleted = true
    
    var dismissCompletion: (() -> Void)?
    
    @IBOutlet weak private var infoLabel: UILabel!
    @IBOutlet weak fileprivate var deleteButton: UIButton!
    @IBOutlet weak private var placeholdersConstrainX: NSLayoutConstraint!
    @IBOutlet fileprivate  var pinCodePlaceholderViews: [PinCodePlaceholderView]!
    
    @IBAction private func pinCodeButtonTapped(_ sender: PinCodeButton) {
        guard isAnimationCompleted == true else { return }
        
        pincodeLock.add(value: sender.actualNumber)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        pincodeLock.removeLast()
        if pincodeLock.passcode.count == 0 { deleteButton.isEnabled = false }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pincodeLock.delegate   = self
        infoLabel.textColor    = OurColors.violet
        deleteButton.isEnabled = false
    }
    
    fileprivate func checkOut(pinCode: [String]) {
        
        let testPinCode = ["1", "2", "3", "4"]
        
        if pincodeLock.attempts > 1 {
            
            isAnimationCompleted  = false
            pincodeLock.attempts -= 1
            
            if pinCode == testPinCode {
                
                if presentingViewController?.presentedViewController == self {
                    
                    dismiss(animated: true, completion: { [weak self] _ in
                        
                        self?.dismissCompletion?()
                    })
                } else if navigationController != nil {
                    
                  _ = navigationController?.popViewController(animated: true)
                }
                
                dismissCompletion?()
            }
            else {
                animateFailedLoginAttempt()
            }
            
            deleteButton.isEnabled = false
            _ = pinCodePlaceholderViews.map { $0.animate(state: .empty) }
        }
        else {
            guard let navController = presentingViewController as? UINavigationController,
                 let presenter = navController.topViewController as? SignInViewController else { return }
            
            presenter.toggleEnterByKeyButton(isEnabled: false)
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    func animateFailedLoginAttempt() {
        
        placeholdersConstrainX.constant -= 40
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: {
                        self.placeholdersConstrainX.constant = 0
                        self.view.layoutIfNeeded()
        }, completion: nil)
        isAnimationCompleted = true
    }
}

extension PinCodeViewController: PinCodeLockDelegate
{
    func addedValue(at index: Int) {
        
        pinCodePlaceholderViews[index].animate(state: .filled)
        deleteButton.isEnabled = true
    }
    
    func removedValue(at index: Int) {
        
        pinCodePlaceholderViews[index].animate(state: .empty)        
    }
    
    func handleAuthorizationBy(pinCode: [String]) {
        
         checkOut(pinCode: pinCode)
    }
}
