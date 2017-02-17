//
//  LaunchViewController.swift
//  CoreKPI
//
//  Created by Семен on 23.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    var request: GetModelFromServer!
    var model: ModelCoreKPI!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let usersPin = UserDefaults.standard.value(forKey: "PinCode") as? [String]
        
        if checkLocalToken() && usersPin != nil {
            tryLoginByPinCode()
            
        } else {
            let startVC = storyboard?.instantiateViewController(withIdentifier: "StartVC")
            present(startVC!, animated: true, completion: nil)
        }
    }
    
    func tryLoginByPinCode() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.pinCodeAttempts = PinLockConfiguration.attempts
        appDelegate.pinCodeVCPresenter.launchController = self
        appDelegate.pinCodeVCPresenter.presentedFromBG = false
        appDelegate.pinCodeVCPresenter.presentPinCodeVC()
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
        
        let req = LoginRequest(model: model)
        req.checkToken(success: { data in
            self.model.token = data.token
            self.model.profile?.userId = data.userID
            self.model.profile?.typeOfAccount = data.typeOfAccount
            self.getDataFromCoreData()
            self.showTabBarVC()
        }, failure: { error in
            self.getDataFromCoreData()
            self.LogOut()
            print(error)
        }
        )
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
        alertsViewController.loadAlerts()
        
        let teamListNavigationViewController = tabBarController.viewControllers?[2] as! TeamListViewController
        let teamListController = teamListNavigationViewController.childViewControllers[0] as! MemberListTableViewController
        teamListController.model = ModelCoreKPI(model: model)
        teamListController.loadTeamListFromServer()
        
        let supportNavigationViewControleler = tabBarController.viewControllers?[3] as! SupportNavigationViewController
        let supportMainTableVC = supportNavigationViewControleler.childViewControllers[0] as! SupportMainTableViewController
        supportMainTableVC.model = ModelCoreKPI(model: model)
        
        present(tabBarController, animated: true, completion: nil)
    }
    
    //MARK: - Get Data from CoreData
    func getDataFromCoreData() {
        let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
        do {
            //model.alerts = try context.fetch(Alert.fetchRequest())
            model.team = try context.fetch(Team.fetchRequest())
        } catch {
            print("Fetching faild")
        }
        //showTabBarVC()
    }
    
    //MARK: - Token incorect
    func LogOut() {
        let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
        
        if model != nil {
            for profile in model.team {
                context.delete(profile)
            }
        }
        else {
            print("DEBUG: Model is nil")
        }
        
        appDelegate.loggedIn = false
        
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "PinCode")
        
        let startVC = storyboard?.instantiateViewController(withIdentifier: "StartVC")
        present(startVC!, animated: true, completion: nil)
    }
    
    func presentStartVC() {
        let startVC = storyboard?.instantiateViewController(withIdentifier: "StartVC")
        present(startVC!, animated: true, completion: nil)
    }
    
}
