//
//  RegisterViewController.swift
//  CoreKPI
//
//  Created by Семен on 15.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var passwordTextField: BottomBorderTextField!
    @IBOutlet weak var emailTextField: BottomBorderTextField!
    @IBOutlet weak var repeatPasswordTextField: BottomBorderTextField!
    
    @IBOutlet weak var registerButton: UIButton!
    
    var email: String!
    var password: String!
    
    var delegate: registerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerButton.layer.borderColor = UIColor(red: 0/255.0, green: 151.0/255.0, blue: 167.0/255.0, alpha: 1.0).cgColor
    }
    
    @IBAction func tapRegisterButton(_ sender: Any) {
        
        email = emailTextField.text?.lowercased()
        password = passwordTextField.text
        let repeatPassword = repeatPasswordTextField.text
        
        if email == "" || password == "" || repeatPassword == "" {
            let alertController = UIAlertController(title: "Oops", message: "All fields must be filled!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        if email?.range(of: "@") == nil || (email?.components(separatedBy: "@")[0].isEmpty)! ||  (email?.components(separatedBy: "@")[1].isEmpty)!{
            let alertController = UIAlertController(title: "Oops", message: "Invalid E-mail adress", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        if password != repeatPassword {
            let alertController = UIAlertController(title: "Oops", message: "Entered passwords are different!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "RegistrationCreateProfileVC") as! NewProfileTableViewController
        delegate = vc
        delegate.updateLoginAndPassword(email: email, password: password)
        navigationController?.pushViewController(vc, animated: true)
    }
    
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
            tapRegisterButton(registerButton)
        }
        return true
    }
    
}
