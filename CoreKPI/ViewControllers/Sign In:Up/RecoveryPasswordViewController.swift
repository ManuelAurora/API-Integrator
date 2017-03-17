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
        self.sendButton.layer.borderColor = UIColor(red: 124.0/255.0, green: 77.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tapSendButton(_ sender: Any) {
        
        let email = emailTextField.text?.lowercased()
        
        if email == "" || email?.range(of: "@") == nil || (email?.components(separatedBy: "@")[0].isEmpty)! ||  (email?.components(separatedBy: "@")[1].isEmpty)!{
            showAlert(title: "Oops", errorMessage: "Invalid E-mail adress")
            return
        } else {
            recoveryPassword(email: email!)
        }
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
    
    //MARK: - show alert function
    func showAlert(title: String, errorMessage: String) {
        let alertController = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
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

