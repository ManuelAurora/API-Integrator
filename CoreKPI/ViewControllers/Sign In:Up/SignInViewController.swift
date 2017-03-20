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
    weak var launchController: LaunchViewController!

    @IBOutlet weak var passwordTextField: BottomBorderTextField!
    @IBOutlet weak var emailTextField: BottomBorderTextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var enterByKeyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        configure(buttons: [signInButton, enterByKeyButton])
        toggleEnterByKeyButton(isEnabled: appDelegate.pinCodeAttempts > 1)

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
        
        guard let pinCodeViewController = storyboard?.instantiateViewController(withIdentifier: "PinCodeViewController") as? PinCodeViewController else { print("DEBUG: An error occured while trying instantiate pin code VC"); return }
        
        pinCodeViewController.mode = .logIn
        present(pinCodeViewController, animated: true, completion: nil)
    }
    
    func toggleEnterByKeyButton(isEnabled: Bool) {
        
        enterByKeyButton.layer.borderColor = isEnabled ? OurColors.violet.cgColor : UIColor.lightGray.cgColor
        enterByKeyButton.isEnabled = isEnabled
    }
    
    func loginRequest() {
        
        if let username = self.emailTextField.text?.lowercased() {
            if let password = self.passwordTextField.text {
                
                let loginRequest = LoginRequest()
                loginRequest.loginRequest(username: username, password: password,
                                          success: {(userID, token, typeOfAccount) in
                                            let profile = Profile(userID: userID)
                                            profile.typeOfAccount = typeOfAccount                                            
                                            self.model.signedInUpWith(token: token, profile: profile)
                                            self.saveData()
                                            self.showTabBarVC()
                                            
                },
                                          failure: { error in
                                            print(error)
                                            self.showAlert(title: "Authorization error", errorMessage: error)
                })
            }
        }
    }
    
    private func showTabBarVC() {
                
        launchController.appDelegate.window?.rootViewController = launchController.mainTabBar
    }
    
    //MARK: - show alert function
    func showAlert(title: String, errorMessage: String) {
        let alertController = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Save data
    func saveData() {
        UserDefaults.standard.set(model.profile.userId, forKey: UserDefaultsKeys.userId)
        UserDefaults.standard.set(model.token, forKey: UserDefaultsKeys.token)
    }
}
