//
//  RecoveryPasswordViewController.swift
//  CoreKPI
//
//  Created by Семен on 15.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit
import Alamofire

class RecoveryPasswordViewController: UIViewController {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeWaitingSpinner()
        removeAllAlamofireNetworking()        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sendButton.layer.borderWidth = 1.0
        self.sendButton.layer.borderColor = OurColors.violet.cgColor
    }
    
    @IBAction func tapSendButton(_ sender: Any) {
        
        toggleUserInterface(enabled: false)
        
        let email = emailTextField.text?.lowercased()
        
        if validate(email: email, password: nil) { recoveryPassword(email: email!) }
        else { showAlert(title: "Error occured", errorMessage: "Invalid E-mail adress") }
    }
    
    func recoveryPassword(email: String) {
        
        let recoveryPasswod = RecoveryPassword()
        recoveryPasswod.recoveryPassword(email: email,
                                         success: {
                                            self.toggleUserInterface(enabled: true)
            self.dismiss(animated: true, completion: nil)
        },
                                         failure: { error in
                                            self.toggleUserInterface(enabled: true)
                                            self.showAlert(title: "Error occured",
                                                           errorMessage: error)
        })
    }
    
    private func toggleUserInterface(enabled: Bool) {
        
        if !enabled
        {
            var point = sendButton.center
            
            point.y += 120
            
            addWaitingSpinner(at: point, color: OurColors.blue)
        }
        else { removeWaitingSpinner(); emailTextField.becomeFirstResponder() }
        
        let violet = OurColors.violet
        let gray   = UIColor.lightGray
        let color  = enabled ? violet : gray
        
        
        sendButton.layer.borderColor = color.cgColor
        sendButton.setTitleColor(color, for: .normal)
        sendButton.isEnabled = enabled
        emailTextField.resignFirstResponder()
        emailTextField.isUserInteractionEnabled = enabled
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

