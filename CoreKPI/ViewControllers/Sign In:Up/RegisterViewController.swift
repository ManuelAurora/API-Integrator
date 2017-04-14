//
//  RegisterViewController.swift
//  CoreKPI
//
//  Created by Семен on 15.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var passwordTextField: BottomBorderTextField!
    @IBOutlet weak var emailTextField: BottomBorderTextField!
    @IBOutlet weak var repeatPasswordTextField: BottomBorderTextField!
    @IBOutlet weak var registerButton: UIButton!
    
    var email: String!
    var password: String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationItem.hidesBackButton = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes = [NSForegroundColorAttributeName : OurColors.cyan]
        navigationController?.navigationBar.titleTextAttributes = attributes
        registerButton.layer.borderColor = OurColors.cyan.cgColor
    }
    
    deinit {
        print("DEBUG: RegisterVC deinitialised")
    }
    
    @IBAction func tapRegisterButton(_ sender: Any) {
        
        let errorTitle = "Error occured"
        
        email = emailTextField.text?.lowercased()
        password = passwordTextField.text
        
        let repeatPassword = repeatPasswordTextField.text
        
        if email == "" && password == "" && repeatPassword == "" {
            showAlert(title: errorTitle, errorMessage: "To successfully register, please enter your email address, a password, and its confirmation.")
        }
        
        if !validate(email: email) { showAlert(title: errorTitle, errorMessage: "Invalid e-mail adress.") }
        
        if !validate(password: password) { showAlert(title: errorTitle, errorMessage: "To proceed, fill password and confirmation text fields.") }
        
        if password != repeatPassword {
            showAlert(title: errorTitle, errorMessage: "Password and its confirmation must be similar.")
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: .newProfViewController) as! NewProfileTableViewController
        vc.updateLoginAndPassword(email: email, password: password)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    
    //MARK: - UITextFieldDelegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        if textField == passwordTextField {
            repeatPasswordTextField.becomeFirstResponder()
        }
        if textField == repeatPasswordTextField {
            emailTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
            repeatPasswordTextField.resignFirstResponder()
            tapRegisterButton(registerButton)
        }
        return true
    }
}
