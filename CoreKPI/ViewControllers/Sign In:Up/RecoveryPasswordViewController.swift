//
//  RecoveryPasswordViewController.swift
//  CoreKPI
//
//  Created by Семен on 15.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit
import Alamofire

class RecoveryPasswordViewController: UIViewController
{
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeWaitingSpinner()
        removeAllAlamofireNetworking()        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
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
        
        let pop: ()->() = {
            self.navigationController?.popViewController(animated: true)
        }
        
        let request = RecoveryPassword()
        
        request.recoveryPassword(email: email,
                                 success: {
                                    self.toggleUserInterface(enabled: true)
                                    let alert = UIAlertController(title: "Success",
                                                                  message: nil,
                                                                  preferredStyle: .alert)
                                    
                                    let okAction = UIAlertAction(title: "Ok",
                                                                 style: .default,
                                                                 handler: { _ in
                                                                    pop()
                                    })
                                    
                                    alert.addAction(okAction)
                                    
                                    self.present(alert,
                                                 animated: true,
                                                 completion: nil)
                                    
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
            let point = sendButton.center
            
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

