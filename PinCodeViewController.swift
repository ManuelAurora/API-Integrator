//
//  PinCodeViewController.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 15.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

enum PinMode: String
{
    case createNewPin
    case logIn
}

class PinCodeViewController: UIViewController
{
    struct TextForLabels
    {
        static let cancel = "Cancel"
        static let delete = "Delete"
        static let confirm = "Confirm Passcode"
        static let newPin = "Enter New Passcode"
        static let enter = "Enter Passcode"
        static let tryAgain = "Try Again"
    }
    
    var pinToConfirm = [String]() {
        didSet {
            if pinToConfirm.count > 0 { infoLabel.text = TextForLabels.confirm }
        }
    }
    
    fileprivate let pincodeLock = PinCodeLock()
    private var isAnimationCompleted = true
    
    weak var presenter: PinCodeVCPresenter!
    weak var delegate: MemberInfoViewController!
    
    var dismissCompletion: (() -> Void)?
    var successCompletion: (() -> Void)?
    var logOutCompletion:  (() -> Void)?
    var cancelledFromBGCompletion: (() -> Void)?
    
    var mode: PinMode?
    var confirmed = false
    var model = ModelCoreKPI.modelShared
    
    
    @IBOutlet var pincodePlaceholderViews: [PinCodePlaceholderView]!
    @IBOutlet weak private var infoLabel: UILabel!
    @IBOutlet weak fileprivate var deleteButton: UIButton!
    @IBOutlet weak private var placeholdersConstrainX: NSLayoutConstraint!
    
    @IBAction private func pinCodeButtonTapped(_ sender: PinCodeButton) {
        guard isAnimationCompleted == true else { return }
        
        pincodeLock.add(value: sender.actualNumber)
        toggleDeleteButton()
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        if sender.titleLabel?.text == TextForLabels.cancel {
            
            if let presenter = presenter {
                if presenter.presentedFromBG {
                    cancelledFromBGCompletion!()
                }
                else {
                    dismissCompletion!()
                }
            }
            else {
                if let presenter = delegate {
                    let cell = presenter.tableView.cellForRow(at: presenter.securityCellIndexPath) as! MemberInfoTableViewCell
                    cell.securitySwitch.isOn = false
                }
                
                dismiss(animated: true, completion: nil)
            }
        }
        else {
            pincodeLock.removeLast()
        }
        toggleDeleteButton()
    }
    
    deinit {
        print("DEBUG: PincodeVC Deinitialized")
    }
    
    convenience init(mode: PinMode) {
        self.init(nibName: "PinCodeView", bundle: nil)
        self.mode = mode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var textForLabel = ""
        
        if let mode = mode
        {
            switch mode
            {
            case .createNewPin:
                textForLabel = TextForLabels.newPin
                
            case PinMode.logIn:
                textForLabel = TextForLabels.enter
            }
        }
        
        infoLabel.text = textForLabel
        
        pincodeLock.delegate = self
        infoLabel.textColor  = OurColors.violet
        toggleDeleteButton()
        deleteButton.setTitleColor(OurColors.violet, for: .normal)
        deleteButton.setTitleColor(.lightGray, for: .disabled)
    }
    
    func createNew(pinCode: [String]) {
        
        if pinToConfirm == pinCode {
            UserDefaults.standard.set(pinCode, forKey: UserDefaultsKeys.pinCode)
            NotificationCenter.default.post(name: .userAddedPincode, object: nil)
            dismiss(animated: true, completion: nil)
        }
        else if pincodeLock.attempts > 1 {
            infoLabel.text = TextForLabels.tryAgain
            pincodeLock.passcode.removeAll()
            pincodeLock.attempts -= 1
            clearAllPlaceholders()
            animateFailedLoginAttempt()
        }
        else {
            
            if let presenter = delegate {
                let cell = presenter.tableView.cellForRow(at: presenter.securityCellIndexPath) as! MemberInfoTableViewCell
                cell.securitySwitch.isOn = false
            }
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func check(_ pinCode: [String]) -> Bool {
        
        let usersPin = UserDefaults.standard.value(forKey: UserDefaultsKeys.pinCode) as? [String] ?? []
        
        return pinCode == usersPin
    }
    
    fileprivate func checkOut(pinCode: [String]) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if !check(pinCode) { appDelegate.pinCodeAttempts -= 1 }
        
        if appDelegate.pinCodeAttempts > 0 {
            
            isAnimationCompleted  = false            
            
            if check(pinCode) {
                
                if presentingViewController?.presentedViewController == self {
                    
                    let navController = self.presentingViewController as! UINavigationController
                    let presentingVC = navController.viewControllers[0] as! SignInViewController
                    
                    presentingVC.model = self.model
                    
                    dismiss(animated: true, completion: { [weak self] _ in
                        self?.isAnimationCompleted = true
                        UserStateMachine.shared.checkTokenOnServer()
                    })
                } else if navigationController != nil {
                    
                  _ = navigationController?.popViewController(animated: true)
                }
                isAnimationCompleted = true
                successCompletion?()
            }
            else {
                animateFailedLoginAttempt()
            }
            
            toggleDeleteButton()
            clearAllPlaceholders()
        }
        else {
            if let navController = presentingViewController as? UINavigationController,
                let presenter = navController.topViewController as? SignInViewController {
                
                UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.token)
                UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.pinCode)
                
                presenter.toggleEnterByKeyButton(isEnabled: false)
                
                dismiss(animated: true, completion: nil)
            }
            else {
                if presenter!.presentedFromBG {
                    logOutCompletion!()
                }
                else if appDelegate.pinCodeAttempts <= 0 {
                    logOutCompletion!()
                }
                else {
                    dismissCompletion!()
                }
            }
        }
    }
    
    fileprivate func toggleDeleteButton() {
        
        let isPassCodeEmpty = pincodeLock.passcode.count == 0
        let title = isPassCodeEmpty ? TextForLabels.cancel : TextForLabels.delete
        
        deleteButton.setTitle(title, for: .normal)
    }
    
    func clearAllPlaceholders() {
        _ = pincodePlaceholderViews.map { $0.animate(state: .empty) }
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
        
        pincodePlaceholderViews[index].animate(state: .filled)
    }
    
    func removedValue(at index: Int) {
        
        pincodePlaceholderViews[index].animate(state: .empty)
    }
    
    func handleAuthorizationBy(pinCode: [String]) {
        
         checkOut(pinCode: pinCode)
    }
}
