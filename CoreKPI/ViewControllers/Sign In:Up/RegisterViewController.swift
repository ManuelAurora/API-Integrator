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
    
    var delegate: registerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : OurColors.cyan]
        registerButton.layer.borderColor = OurColors.cyan.cgColor
    }
    
    @IBAction func tapRegisterButton(_ sender: Any) {
        
        let errorTitle = "Error occured"
        
        email = emailTextField.text?.lowercased()
        password = passwordTextField.text
        
        let repeatPassword = repeatPasswordTextField.text
        
        if email == "" || password == "" || repeatPassword == "" {
            showAlert(title: errorTitle, errorMessage: "All fields must be filled!")
            return
        }
        
        if !validate(email: email, password: nil) { showAlert(title: errorTitle, errorMessage: "Invalid E-mail adress") }
        
        if password != repeatPassword {
            showAlert(title: errorTitle, errorMessage: "Entered passwords are different!")
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: .registerViewController) as! NewProfileTableViewController
        delegate = vc
        delegate.updateLoginAndPassword(email: email, password: password)
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
