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
        
    @IBOutlet weak var passwordTextField: BottomBorderTextField!
    @IBOutlet weak var emailTextField: BottomBorderTextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var enterByKeyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        subscribeNotifications()
    }
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        configure(buttons: [signInButton, enterByKeyButton])
        toggleEnterByKeyButton(isEnabled: appDelegate.pinCodeAttempts > 0)
    }    
    
    //MARK: - UITextFieldDelegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
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
        
        if email == "" || password == "" {
            showAlert(title: "Oops", errorMessage: "Email/Password field is empty!")
            return
        }
        
        if email?.range(of: "@") == nil || (email?.components(separatedBy: "@")[0].isEmpty)! ||  (email?.components(separatedBy: "@")[1].isEmpty)!{
            showAlert(title: "Oops", errorMessage: "Invalid E-mail adress")
            return
        }
        
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        loginRequest()
    }
    
    private func configure(buttons: [UIButton]) {
        
        _ = buttons.map {
            $0.layer.borderWidth = 1.0
            $0.layer.borderColor = UIColor(red: 124.0/255.0, green: 77.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        }
    }
    
    private func showPinCodeViewController() {
        
        guard let pinCodeViewController = storyboard?.instantiateViewController(withIdentifier: "PinCodeViewController") as? PinCodeViewController else { print("DEBUG: An error occured while trying instantiate pincode VC"); return }
        
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
    
    //MARK: - show alert function
    private func showAlert(title: String, errorMessage: String) {
        let alertController = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }    
}
