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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if checkLocalToken() {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.pinCodeVCPresenter.launchController = self
            appDelegate.pinCodeVCPresenter.presentPinCodeVC()            
            
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
        for profile in model.team {
            context.delete(profile)
        }
        UserDefaults.standard.removeObject(forKey: "token")
        
        let startVC = storyboard?.instantiateViewController(withIdentifier: "StartVC")
        present(startVC!, animated: true, completion: nil)
    }
    
}
