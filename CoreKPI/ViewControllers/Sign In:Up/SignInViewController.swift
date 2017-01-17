//
//  SignInViewController.swift
//  CoreKPI
//
//  Created by Семен on 15.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    var request = Request()
    var model: ModelCoreKPI!
    var delegate: updateModelDelegate!
    
    @IBOutlet weak var passwordTextField: BottomBorderTextField!
    @IBOutlet weak var emailTextField: BottomBorderTextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signInButton.layer.borderWidth = 1.0
        self.signInButton.layer.borderColor = UIColor(red: 124.0/255.0, green: 77.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - UITextFieldDelegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            emailTextField.resignFirstResponder()
            tapSignInButton(signInButton)
        }
        return true
    }
    
    @IBAction func tapSignInButton(_ sender: UIButton) {
        
        let email = emailTextField.text?.lowercased()
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
        
        if let username = self.emailTextField.text?.lowercased() {
            if let password = self.passwordTextField.text {
                
                let data: [String : Any] = ["username" : username, "password" : password]
                
                request.getJson(category: "/auth/auth", data: data,
                                success: { json in
                                    self.parsingJson(json: json)
                                    
                },
                                failure: { (error) in
                                    print(error)
                                    self.showAlert(title: "Authorization error", errorMessage: error)
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
                    self.request = Request(userId: userId, token: token)
                    getUserProfileFromServer()
                } else {
                    print("Json data is broken")
                }
            } else {
                let errorMessage = json["message"] as! String
                print("Json error message: \(errorMessage)")
                showAlert(title: "Authorization error", errorMessage: errorMessage)
            }
        } else {
            print("Json file is broken!")
        }
    }
    
    func getUserProfileFromServer() {
        request.getJson(category: "/account/contactData", data: [:],
                        success: { json in
                            self.createModel(json: json)
                            
        },
                        failure: { (error) in
                            print(error + "Can not get user's profile.")
        })
        
    }
    
    func createModel(json: NSDictionary) {
        
        var profile: Profile!
        var userName: String!
        var firstName: String!
        var lastName: String!
        var position: String!
        var photo: String!
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSDictionary {
                    userName = dataKey["username"] as! String
                    firstName = dataKey["first_name"] as! String
                    lastName = dataKey["last_name"] as! String
                    position = dataKey["position"] as! String
                    photo = dataKey["photo"] as! String
                    
                    profile = Profile(userId: request.userID, userName: userName, firstName: firstName, lastName: lastName, position: position, photo: photo, phone: nil, nickname: nil, typeOfAccount: .Admin)
                    
                    self.model = ModelCoreKPI(token: request.token, profile: profile)
                    self.saveData()
                    
                    let tabBarController = storyboard?.instantiateViewController(withIdentifier: "TabBarVC") as! MainTabBarViewController
                    
                    let dashboardNavigationViewController = tabBarController.viewControllers?[0] as! DashboardsNavigationViewController
                    let dashboardViewController = dashboardNavigationViewController.childViewControllers[0] as! KPIsListTableViewController
                    dashboardViewController.model = ModelCoreKPI(model: model)
                    dashboardViewController.loadKPIsFromServer()
                    
                    let alertsNavigationViewController = tabBarController.viewControllers?[1] as! AlertsNavigationViewController
                    let alertsViewController = alertsNavigationViewController.childViewControllers[0] as! AlertsListTableViewController
                    alertsViewController.model = ModelCoreKPI(model: model)
                    
                    let teamListNavigationViewController = tabBarController.viewControllers?[2] as! TeamListViewController
                    let teamListController = teamListNavigationViewController.childViewControllers[0] as! MemberListTableViewController
                    teamListController.model = ModelCoreKPI(model: model)
                    
                    present(tabBarController, animated: true, completion: nil)
                    
                } else {
                    print("Json data is broken")
                }
            } else {
                let errorMessage = json["message"] as! String
                print("Json error message: \(errorMessage)")
                showAlert(title: "Authorization error",errorMessage: errorMessage)
            }
        } else {
            print("Json file is broken!")
        }
    }
    //MARK: - show alert function
    func showAlert(title: String, errorMessage: String) {
        let alertController = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Save data
    func saveData() {
        print("Data not save")
    }
    
}
