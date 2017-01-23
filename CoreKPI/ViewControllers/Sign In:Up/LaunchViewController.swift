//
//  LaunchViewController.swift
//  CoreKPI
//
//  Created by Семен on 23.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    var request = Request()
    var model: ModelCoreKPI!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if checkLocalToken() {
            getModelFromServer()
            getDataFromCoreData()
        } else {
            let startVC = storyboard?.instantiateViewController(withIdentifier: "StartVC")
            present(startVC!, animated: true, completion: nil)
        }
    }
    
    func checkLocalToken() -> Bool {
        if let data = UserDefaults.standard.data(forKey: "token"),
            let myTokenArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [ModelCoreKPI] {
            model = ModelCoreKPI(model: myTokenArray[0])
            return true
        } else {
            print("No local token in app storage")
            return false
        }
    }
    
    func getModelFromServer() {
        request = Request(model: model)
        request.getJson(category: "/account/contactData", data: [:],
                        success: { json in
                            self.createModel(json: json)
                            
        },
                        failure: { (error) in
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
                    
                    model.profile = profile
                    showTabBarVC()
                    
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
        present(alertController, animated: true, completion: nil)
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
    
    //MARK: - Get Data from CoreData
    
    func getDataFromCoreData() {
        let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
        do {
            model.team = try context.fetch(Team.fetchRequest())
        } catch {
            print("Fetching faild")
        }
    }
}
