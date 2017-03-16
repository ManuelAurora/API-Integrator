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
    var model = ModelCoreKPI.modelShared
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var showedAfterBGCancelling = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let usersPin = UserDefaults.standard.value(forKey: UserDefaultsKeys.pinCode) as? [String]
        
        if checkLocalToken()
        {
            if usersPin != nil && showedAfterBGCancelling == false
            {
                tryLoginByPinCode()
            }
            else if usersPin == nil
            {
                checkTokenOnServer()
            }
            else
            {
                presentStartVC()
            }
        }
        else {
            presentStartVC()
        }
    }
    
    func tryLoginByPinCode() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.pinCodeVCPresenter.launchController = self
        appDelegate.pinCodeVCPresenter.presentedFromBG = false
        appDelegate.pinCodeVCPresenter.presentPinCodeVC()
    }
    
    func checkLocalToken() -> Bool {
        
        if let token = UserDefaults.standard.object(forKey: UserDefaultsKeys.token)
        {
            let userID = UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId)
            
            guard userID != 0 else { print("DEBUG: User ID equals 0"); return false }
            
            let profile = Profile(userID: userID)
            
            model.profile = profile
            model.token = token as! String
            
            return true
        } else {
            print("No local token in app storage")
            return false
        }
    }
    
    func checkTokenOnServer() {
        
        let req = LoginRequest(model: model)
        req.checkToken(success: { data in
            self.model.token = data.token
            self.model.profile?.userId = data.userID
            self.model.profile?.typeOfAccount = data.typeOfAccount
            self.getDataFromCoreData()
            self.showTabBarVC()
        }, failure: { error in
            if error == "" { //TODO: Токен невалидный
                self.getDataFromCoreData()
                self.LogOut()
            } else {
                self.getDataFromCoreData()
                self.showTabBarVC()
            }
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
        dashboardViewController.model = model
        dashboardViewController.loadKPIsFromServer()
        
        let alertsNavigationViewController = tabBarController.viewControllers?[1] as! AlertsNavigationViewController
        let alertsViewController = alertsNavigationViewController.childViewControllers[0] as! AlertsListTableViewController
        alertsViewController.model = model
        alertsViewController.loadAlerts()
        
        let teamListNavigationViewController = tabBarController.viewControllers?[2] as! TeamListViewController
        let teamListController = teamListNavigationViewController.childViewControllers[0] as! MemberListTableViewController
        teamListController.model = model
        teamListController.loadTeamListFromServer()
        
        let supportNavigationViewControleler = tabBarController.viewControllers?[3] as! SupportNavigationViewController
        let supportMainTableVC = supportNavigationViewControleler.childViewControllers[0] as! SupportMainTableViewController
        supportMainTableVC.model = model
        
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
    }
    
    //MARK: - Token incorect
    func LogOut() {
        let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
        
        _ = model.team.map { context.delete($0) }
        
        appDelegate.loggedIn = false
        
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.token)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.pinCode)
        
        presentStartVC()
    }
    
    func presentStartVC() {
        let startVC = storyboard?.instantiateViewController(withIdentifier: "StartVC")
        present(startVC!, animated: true, completion: nil)
    }
    
}
