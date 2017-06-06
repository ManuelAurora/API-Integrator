//
//  RegisterViewController.swift
//  CoreKPI
//
//  Created by Семен on 15.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, StoryboardInstantiation {
    
    @IBOutlet weak var passwordTextField: BottomBorderTextField!
    @IBOutlet weak var emailTextField: BottomBorderTextField!
    @IBOutlet weak var repeatPasswordTextField: BottomBorderTextField!
    @IBOutlet weak var registerButton: UIButton!
    
    var email: String!
    var password: String!
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.isNavigationBarHidden = false        
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
    
    func clearTextFields() {
        
        guard passwordTextField != nil, emailTextField != nil else { return }
        
        passwordTextField.text = ""
        repeatPasswordTextField.text = ""
        emailTextField.text = ""
        emailTextField.becomeFirstResponder()
    }
    
    @IBAction func registeredButtonTapped(_ sender: UIButton) {
        
        if navigationController?.viewControllers[1] is SignInViewController
        {
            navigationController?.popViewController(animated: true)
        }
        else
        {
            let controller = appDelegate.launchViewController.signInVC
            navigationController?.pushViewController(controller, animated: true)
        }        
    }
    
    @IBAction func tapRegisterButton(_ sender: Any) {
        
        let errorTitle = "Error occured"
        
        email = emailTextField.text?.lowercased()
        password = passwordTextField.text
        
        let repeatPassword = repeatPasswordTextField.text
        
        if email == "" && password == "" && repeatPassword == ""
        {
            showAlert(title: errorTitle,
                      errorMessage: "To successfully register, please enter" +
                                    " your email address, a password, and" +
                                    " its confirmation.")
        }
        
        if !validate(email: email) {
            showAlert(title: errorTitle,
                      errorMessage: "Invalid e-mail adress.")
        }
        
        if !validate(password: password)
        {
            showAlert(title: errorTitle,
                      errorMessage: "To proceed, fill password and" +
                                    " confirmation text fields.")
        }
        
        if password != repeatPassword
        {
            showAlert(title: errorTitle,
                      errorMessage: "Password and its confirmation" +
                                    " must be similar.")
        }
        
        let vc = NewProfileTableViewController.storyboardInstance()
        
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
