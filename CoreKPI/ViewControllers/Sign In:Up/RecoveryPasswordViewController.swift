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
    
    let request = Request()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sendButton.layer.borderWidth = 1.0
        self.sendButton.layer.borderColor = UIColor(red: 124.0/255.0, green: 77.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapSendButton(_ sender: Any) {
        
        let email = emailTextField.text?.lowercased()
        
        if email == "" || email?.range(of: "@") == nil || (email?.components(separatedBy: "@")[0].isEmpty)! ||  (email?.components(separatedBy: "@")[1].isEmpty)!{
            let alertController = UIAlertController(title: "Oops", message: "Invalid E-mail adress", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        } else {
            recoveryPassword(email: email!)
        }
    }
    
    func recoveryPassword(email: String) {
        
        let data: [String : Any] = ["email" : email]
        
        request.getJson(category: "/auth/recovery", data: data, //debug!
                        success: { json in
                            self.parsingJson(json: json)
                            
        },
                        failure: { (error) in
                            print(error)
                            let alertController = UIAlertController(title: "Sorry!", message: error, preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    func parsingJson(json: NSDictionary) {
        
        if let successKey = json["success"] as? Int {
            if successKey == 0 {
                let errorMessage = json["message"] as! String
                print("Json error message: \(errorMessage)")
                let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            print("Json file is broken!")
        }
    }
    
}
