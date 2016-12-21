//
//  SignInViewController.swift
//  CoreKPI
//
//  Created by Семен on 15.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    let request = Request()
    var model: ModelCoreKPI!
    
    @IBOutlet weak var passwordTextField: BottomBorderTextField!
    @IBOutlet weak var emailTextField: BottomBorderTextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signInButton.layer.borderWidth = 1.0
        self.signInButton.layer.borderColor = UIColor(red: 124.0/255.0, green: 77.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        
        self.emailTextField.keyboardType = UIKeyboardType.emailAddress
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapSignInButton(_ sender: UIButton) {
        
        let email = emailTextField.text
        let password = passwordTextField.text
        
        if email == "" || password == "" {
            
            let alertController = UIAlertController(title: "Oops", message: "Email/Password field is empty!", preferredStyle: UIAlertControllerStyle.alert)
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
        
        loginRequest()
    }
    
    func loginRequest() {
        
        if let username = self.emailTextField.text {
            if let password = self.passwordTextField.text {
                
                let data: [String : Any] = ["username" : username, "password" : password]
                
                request.getJson(category: "/auth/auth", data: data,
                                success: { json in
                                    self.parsingJson(json: json)
                                    
                },
                                failure: { (error) in
                                    print(error)
                })
            }
        }
    }
    
    func parsingJson(json: NSDictionary) {
        var userId: Int
        var token: String
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSDictionary {
                    userId = dataKey["user_id"] as! Int
                    token = dataKey["token"] as! String
                    model = ModelCoreKPI(userId: userId, token: token, profile: nil)
                    let vc = storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
                    present(vc!, animated: true, completion: nil)
                } else {
                    print("Json data is broken")
                }
            } else {
                let errorMessage = json["message"] as! String
                print("Json error message: \(errorMessage)")
                showAlert(errorMessage: errorMessage)
            }
        } else {
            print("Json file is broken!")
        }
    }
    
    func showAlert(errorMessage: String) {
        let alertController = UIAlertController(title: "Authorization error", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}
