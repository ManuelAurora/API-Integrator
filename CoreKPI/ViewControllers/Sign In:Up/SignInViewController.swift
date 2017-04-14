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
    @IBOutlet var auxillaryButtons: [UIButton]!
    
    deinit {
        print("DEBUG: SignInVC deinitialized")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        subscribeNotifications()
    }
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configure(buttons: [signInButton, enterByKeyButton])
        toggleEnterByKeyButton(isEnabled: stateMachine.pinCodeAttempts > 0)
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
        
        enterByKeyButton?.layer.borderColor = isEnabled ? OurColors.violet.cgColor : UIColor.lightGray.cgColor
        enterByKeyButton?.isEnabled = isEnabled
    }
    
    private func toggleSignInEnterByKeyButtons(isEnabled: Bool) {
        
        let violet = OurColors.violet.cgColor
        let gray   = UIColor.lightGray.cgColor
        
        enterByKeyButton.layer.borderColor = isEnabled ? violet : gray
        signInButton.layer.borderColor     = isEnabled ? violet : gray
        signInButton.isEnabled     = isEnabled
        enterByKeyButton.isEnabled = isEnabled
    }
    
    func clearTextFields() {
        
        guard passwordTextField != nil, emailTextField != nil else { return }
        
        passwordTextField.text = ""
        emailTextField.text = ""
        emailTextField.becomeFirstResponder()
    }
    
    private func loginRequest() {
        if let username = self.emailTextField.text?.lowercased() {
            if let password = self.passwordTextField.text {
                stateMachine.logInWith(email: username, password: password)
                toggleSignInAnimation()
            }
        }
    }
    
    @objc private func userFailedToLogin(_ notification: Notification) {
        
        toggleSignInAnimation()
        
        if let error = notification.userInfo?["error"] as? String
        {
            showAlert(title: "Authorization failed", errorMessage: error)
        }
    }
    
    func toggleSignInAnimation() {
        
        let tryingToLogin = stateMachine.userStateInfo.tryingToLogIn
        let usesPin = stateMachine.userStateInfo.usesPinCode
        
        UIView.animate(withDuration: 0.3, animations: {
            let alpha: CGFloat = tryingToLogin ? 0 : 1
            self.auxillaryButtons.forEach { $0.alpha = alpha }
        })
        
        emailTextField.isUserInteractionEnabled = !tryingToLogin
        passwordTextField.isUserInteractionEnabled = !tryingToLogin
       
        toggleSignInEnterByKeyButtons(isEnabled: !tryingToLogin)
        toggleEnterByKeyButton(isEnabled: !tryingToLogin && usesPin)
        
        if tryingToLogin
        {
            var point = enterByKeyButton.center
            point.y += 85
            
            addWaitingSpinner(at: point, color: OurColors.blue)
        }
        else
        {
            removeWaitingSpinner()
        }
    }
    
    private func subscribeNotifications() {
        
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(SignInViewController.userFailedToLogin),
                       name: .userFailedToLogin,
                       object: nil)
        
        nc.addObserver(forName: .userLoggedOut, object: nil, queue: nil) { [weak self] _ in
            self?.clearTextFields()
        }
        
        nc.addObserver(forName: .userLoggedIn, object: nil, queue: nil) {
            [weak self] _ in
            self?.toggleSignInAnimation()
        }
    }    
}
