//
//  InviteTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 15.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class InviteTableViewController: UITableViewController, updateModelDelegate, updateTypeOfAccountDelegate {
    
    @IBOutlet weak var typeOfAccountLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var positionTextField: UITextField!
    @IBOutlet weak var numberOfInvationsLAbel: UILabel!
    
    var model: ModelCoreKPI!
    var invitePerson: Profile!
    
    var typeOfAccount = TypeOfAccount.Manager
    
    var numberOfInvations = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.numberOfInvations = 3 //Test
        self.numberOfInvationsLAbel.text = "\(numberOfInvations) invitations left"
        self.typeOfAccountLabel.text = self.typeOfAccount.rawValue
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  section == 0 {
            return 5
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 4 {
            
            if numberOfInvations < 1 {
                let alertController = UIAlertController(title: "error", message: "You have not more invations!", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(alertController, animated: true, completion: nil)
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            if firstNameTextField.text == "" || emailTextField.text == "" || positionTextField.text == "" {
                let alertController = UIAlertController(title: "error", message: "Field(s) are emty!", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(alertController, animated: true, completion: nil)
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            if emailTextField.text!.range(of: "@") == nil || (emailTextField.text!.components(separatedBy: "@")[0].isEmpty) ||  (emailTextField.text!.components(separatedBy: "@")[1].isEmpty) {
                let alertController = UIAlertController(title: "Oops", message: "Invalid E-mail adress", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            let alertController = UIAlertController(title: "Send invation", message: "We’ll send an invation to \(firstNameTextField.text!) \(emailTextField.text!)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Send", style: .default, handler:{
                (action: UIAlertAction!) -> Void in
                self.sendInvations()
            }))
            self.present(alertController, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addInvites(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Need more invitations?", message: "You more invitations left. Would you like to buy more?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Buy", style: .default, handler: nil))
        //Add buying!
        alertController.addAction(UIAlertAction(title: "No thanks", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    //Function for send invations on server
    func sendInvations() {
        print("send invations")
    }
    
    //MARK: - updateModelDelegate methods
    
    func updateModel(model: ModelCoreKPI) {
        self.model = ModelCoreKPI(model: model)
    }
    
    //MARK: - updateTypeOfAccountDelegate method
    
    func updateTypeOfAccount(typeOfAccount: TypeOfAccount) {
        self.typeOfAccount = typeOfAccount
        tableView.reloadData()
    }
    
    //MARK: - prepare for navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "TabBarFromInvite" {
            
            let tabBarController = segue.destination as! MainTabBarViewController
            
            let dashboardNavigationViewController = tabBarController.viewControllers?[0] as! DashboardsNavigationViewController
            let dashboardViewController = dashboardNavigationViewController.childViewControllers[0] as! KPIsListTableViewController
            dashboardViewController.model = ModelCoreKPI(model: model)
            
            let alertsNavigationViewController = tabBarController.viewControllers?[1] as! AlertsNavigationViewController
            let alertsViewController = alertsNavigationViewController.childViewControllers[0] as! AlertsListTableViewController
            alertsViewController.model = ModelCoreKPI(model: model)
            
            let teamListNavigationViewController = tabBarController.viewControllers?[2] as! TeamListViewController
            let teamListController = teamListNavigationViewController.childViewControllers[0] as! MemberListTableViewController
            teamListController.model = ModelCoreKPI(model: model)
        }
        
        if segue.identifier == "TypeOfNewAccount" {
            let destinationViewController = segue.destination as! TypeOfAccountTableViewController
            destinationViewController.typeOfAccount = self.typeOfAccount
        }
    }
    
}
