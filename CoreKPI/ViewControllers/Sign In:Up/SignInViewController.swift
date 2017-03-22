//
//  SignInViewController.swift
//  CoreKPI
//
//  Created by Семен on 15.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    var model: ModelCoreKPI!   
    let stateMachine = UserStateMachine.shared
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var passwordTextField: BottomBorderTextField!
    @IBOutlet weak var emailTextField: BottomBorderTextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var enterByKeyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        subscribeNotifications()
    }
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configure(buttons: [signInButton, enterByKeyButton])
        toggleEnterByKeyButton(isEnabled: appDelegate.pinCodeAttempts > 0)
    }    
    
    //MARK: - UITextFieldDelegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField { passwordTextField.becomeFirstResponder() }
        else
        {
            emailTextField.resignFirstResponder()
            tapSignInButton(signInButton)
        }
        return true
    }
    
    @IBAction func enterByKeyButtonTapped(_ sender: UIButton) {
        
        showPinCodeViewController()
    }
    
    @IBAction func tapSignInButton(_ sender: UIButton) {
        
        let email = emailTextField.text?.lowercased()
        let password = passwordTextField.text
        
        if validate(email: email, password: password)
        {
            passwordTextField.resignFirstResponder()
            emailTextField.resignFirstResponder()
            loginRequest()
        }
        else { showAlert(title: "Error occured", errorMessage: "Incorrect email and/or password") }
    }
    
    private func configure(buttons: [UIButton]) {
        
        _ = buttons.map {
            $0.layer.borderWidth = 1.0
            $0.layer.borderColor = OurColors.violet.cgColor
        }
    }
    
    private func showPinCodeViewController() {
        
        guard let pinCodeViewController = storyboard?.instantiateViewController(withIdentifier: .pincodeViewController) as? PinCodeViewController else { print("DEBUG: An error occured while trying instantiate pincode VC"); return }
        
        pinCodeViewController.mode = .logIn
        present(pinCodeViewController, animated: true, completion: nil)
    }
    
    func toggleEnterByKeyButton(isEnabled: Bool) {
        
        enterByKeyButton.layer.borderColor = isEnabled ? OurColors.violet.cgColor : UIColor.lightGray.cgColor
        enterByKeyButton.isEnabled = isEnabled
    }
    
    func clearTextFields() {
        
        passwordTextField.text = ""
        emailTextField.text = ""
        emailTextField.becomeFirstResponder()
    }
    
    private func loginRequest() {
        
        if let username = self.emailTextField.text?.lowercased() {
            if let password = self.passwordTextField.text {
                stateMachine.logInWith(email: username, password: password)
            }
        }
    }
    
    @objc private func userFailedToLogin(_ notification: Notification) {
        
        if let error = notification.userInfo?["error"] as? String
        {
            showAlert(title: "Authorization failed", errorMessage: error)
        }
    }
    
    private func subscribeNotifications() {
        
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(SignInViewController.userFailedToLogin),
                       name: .userFailedToLogin,
                       object: nil)
    }    
}
