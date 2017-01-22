//
//  SignInUpViewController.swift
//  CoreKPI
//
//  Created by Семен on 14.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class SignInUpViewController: UIViewController {
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    var request = Request()
    var model: ModelCoreKPI!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set border for buttons
        self.signInButton.layer.borderWidth = 1.0
        self.signInButton.layer.borderColor = UIColor(red: 124.0/255.0, green: 77.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        self.registerButton.layer.borderWidth = 1.0
        self.registerButton.layer.borderColor = UIColor(red: 0/255.0, green: 151.0/255.0, blue: 167.0/255.0, alpha: 1.0).cgColor
        
        //MARK: - Check local user_id/token and segue to TabBarView
        
        if checkLocalToken() {
            getModelFromServer()
            
        } else {
            print("No local token in app storage")
        }
        
    }
    
    func checkLocalToken() -> Bool {
        if let data = UserDefaults.standard.data(forKey: "token"),
            let myTokenArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [ModelCoreKPI] {
           self.model = ModelCoreKPI(model: myTokenArray[0])
            return true
        } else {
            print("There is an issue")
            return false
        }
        
    }
    
    func getModelFromServer() {
        request = Request(model: self.model)
        request.getJson(category: "/account/contactData", data: [:],
                        success: { json in
                            self.createModel(json: json)
                            
        },
                        failure: { (error) in
                            self.showAlert(title: "Error", errorMessage: error)
                            self.showTabBarVC()
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
                    self.showTabBarVC()
                    
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
    
    func showTabBarVC() {
        
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
    }
    
}
