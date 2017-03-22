//
//  RecoveryPasswordViewController.swift
//  CoreKPI
//
//  Created by Семен on 15.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class RecoveryPasswordViewController: UIViewController {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sendButton.layer.borderWidth = 1.0
        self.sendButton.layer.borderColor = OurColors.violet.cgColor
    }
    
    @IBAction func tapSendButton(_ sender: Any) {
        
        let email = emailTextField.text?.lowercased()
        
        if validate(email: email, password: nil) { recoveryPassword(email: email!) }
        else { showAlert(title: "Error occured", errorMessage: "Invalid E-mail adress") }
    }
    
    func recoveryPassword(email: String) {
        
        let recoveryPasswod = RecoveryPassword()
        recoveryPasswod.recoveryPassword(email: email,
                                         success: {
            self.dismiss(animated: true, completion: nil)
        },
                                         failure: { error in
                                            self.showAlert(title: "Sorry!", errorMessage: error)
        })
    }
}

    //MARK: - UITextFieldDelegate method
    extension RecoveryPasswordViewController: UITextFieldDelegate {
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if textField == emailTextField {
                emailTextField.resignFirstResponder()
                self.tapSendButton(sendButton)
            }
            return true
    }
}

