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
    
    var presenter: PinCodeVCPresenter?
    var dismissCompletion: (() -> Void)?
    var successCompletion: (() -> Void)?
    
    lazy var model: ModelCoreKPI? = {
        if let data = UserDefaults.standard.data(forKey: "token"),
            let myTokenArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [ModelCoreKPI] {
            let model = ModelCoreKPI(model: myTokenArray[0])
            return model
        }
        
        return nil
    }()
    
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
        deleteButton.setTitleColor(OurColors.violet, for: .normal)
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
                        self?.successCompletion?()
                    })
                } else if navigationController != nil {
                    
                  _ = navigationController?.popViewController(animated: true)
                }
                
                dismissCompletion?()
                successCompletion?()
            }
            else {
                animateFailedLoginAttempt()
            }
            
            deleteButton.isEnabled = false
            _ = pinCodePlaceholderViews.map { $0.animate(state: .empty) }
        }
        else {
            if let navController = presentingViewController as? UINavigationController,
                let presenter = navController.topViewController as? SignInViewController {
                
                presenter.toggleEnterByKeyButton(isEnabled: false)
                
                dismiss(animated: true, completion: nil)
            }
            else {
                dismissCompletion!()
                logOut()
            }
        }
    }
    
    private func logOut() {
        
        let appDelegate = UIApplication.shared .delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        if let model = model {
        for profile in model.team {
            context.delete(profile)
            }
        }
        
        UserDefaults.standard.removeObject(forKey: "token")
        appDelegate.loggedIn = false
        
        let startVC = storyboard?.instantiateViewController(withIdentifier: "StartVC")
        present(startVC!, animated: true, completion: nil)
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
