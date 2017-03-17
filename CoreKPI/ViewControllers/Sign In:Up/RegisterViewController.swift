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
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 0/255.0, green: 151.0/255.0, blue: 167.0/255.0, alpha: 1.0)]
        registerButton.layer.borderColor = UIColor(red: 0/255.0, green: 151.0/255.0, blue: 167.0/255.0, alpha: 1.0).cgColor
    }
    
    @IBAction func tapRegisterButton(_ sender: Any) {
        
        email = emailTextField.text?.lowercased()
        password = passwordTextField.text
        let repeatPassword = repeatPasswordTextField.text
        
        if email == "" || password == "" || repeatPassword == "" {
            showAlert(title: "Oops", errorMessage: "All fields must be filled!")
            return
        }
        
        if email?.range(of: "@") == nil || (email?.components(separatedBy: "@")[0].isEmpty)! ||  (email?.components(separatedBy: "@")[1].isEmpty)!{
            showAlert(title: "Oops", errorMessage: "Invalid E-mail adress")
            return
        }
        
        if password != repeatPassword {
            showAlert(title: "Oops", errorMessage: "Entered passwords are different!")
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "RegistrationCreateProfileVC") as! NewProfileTableViewController
        delegate = vc
        delegate.updateLoginAndPassword(email: email, password: password)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - show alert function
    func showAlert(title: String, errorMessage: String) {
        let alertController = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
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
