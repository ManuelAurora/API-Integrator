//
//  InviteTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 15.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class InviteTableViewController: UITableViewController {
    
    @IBOutlet weak var typeOfAccountLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var numberOfInvationsLAbel: UILabel!
    
    var model: ModelCoreKPI!
    var invitePerson: Profile!
    var typeOfAccount = TypeOfAccount.Manager
    
    var numberOfInvations = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getNumberOfInvations()
        numberOfInvationsLAbel.text = "\(numberOfInvations) invitations left"
        typeOfAccountLabel.text = typeOfAccount.rawValue
        
        let controllers = navigationController?.viewControllers
        
        if controllers?[(controllers?.count)! - 2] is NewProfileTableViewController {
            navigationItem.hidesBackButton = true
        }
        
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
            return 3
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            tapInviteButton()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
    //MARK: - Invite button did taped
    func tapInviteButton() {
        if numberOfInvations < 1 {
            showAlert(title: "Error", message: "You have not more invations!")
            return
        }
        if emailTextField.text == "" {
            showAlert(title: "Error", message: "Field(s) are emty!")
            return
        }
        if emailTextField.text!.range(of: "@") == nil || (emailTextField.text!.components(separatedBy: "@")[0].isEmpty) ||  (emailTextField.text!.components(separatedBy: "@")[1].isEmpty) {
            showAlert(title: "Oops", message: "Invalid E-mail adress")
            return
        }
        let alertController = UIAlertController(title: "Send invation", message: "We’ll send an invation to \(emailTextField.text!)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Send", style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.sendInvations()
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addInvites(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Need more invitations?", message: "You more invitations left. Would you like to buy more?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Buy", style: .default, handler: nil))
        //Add buying!
        alertController.addAction(UIAlertAction(title: "No thanks", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
        
    }
    
    //MARK: - Function for send invations on server
    func sendInvations() {
        
        let emailLowercased = emailTextField.text?.lowercased()
        
        let inviteRequest = SendInvation(model: model)
        inviteRequest.sendInvations(email: emailLowercased!, typeOfAccount: typeOfAccount, success: {number in
            self.showAlert(title: "Congratulation!", message: "You send invation for \(self.emailTextField.text!)")
            self.emailTextField.text = ""
            self.numberOfInvations = number
            self.numberOfInvationsLAbel.text = "\(self.numberOfInvations) invitations left"
            self.typeOfAccount = .Manager
            self.typeOfAccountLabel.text = self.typeOfAccount.rawValue
            self.tableView.reloadData()
        }, failure: { error in
        self.showAlert(title: "Send invation error", message: error)
        }
        )
    }
    
    //MARK: - show alert function
    func showAlert(title: String ,message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - prepare for navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "TabBarFromInvite" {
            
            let tabBarController = segue.destination as! MainTabBarViewController
            
            let dashboardNavigationViewController = tabBarController.viewControllers?[0] as! DashboardsNavigationViewController
            let dashboardViewController = dashboardNavigationViewController.childViewControllers[0] as! KPIsListTableViewController
            dashboardViewController.model = model
            
            let alertsNavigationViewController = tabBarController.viewControllers?[1] as! AlertsNavigationViewController
            let alertsViewController = alertsNavigationViewController.childViewControllers[0] as! AlertsListTableViewController
            alertsViewController.model = model
            
            let teamListNavigationViewController = tabBarController.viewControllers?[2] as! TeamListViewController
            let teamListController = teamListNavigationViewController.childViewControllers[0] as! MemberListTableViewController
            teamListController.model = model
        }
        
        if segue.identifier == "TypeOfNewAccount" {
            let destinationViewController = segue.destination as! TypeOfAccountTableViewController
            destinationViewController.typeOfAccount = self.typeOfAccount
            destinationViewController.InviteVC = self
        }
    }
    
    //MARK: - get number of invations from server
    func getNumberOfInvations() {
        
        let request = GetNumberOfInvations(model: model)
        request.getNumberOfInvations(success: { number in
            self.numberOfInvations = number
            self.numberOfInvationsLAbel.text = "\(self.numberOfInvations) invitations left"
        }, failure: { error in
            self.showAlert(title: "Sorry!", message: error)
        }
        )
    }
    
}

////MARK: - updateModelDelegate methods
//extension InviteTableViewController: updateModelDelegate {
//    func updateModel(model: ModelCoreKPI) {
//        self.model = ModelCoreKPI(model: model)
//    }
//}

//MARK: - updateTypeOfAccountDelegate method
extension InviteTableViewController: updateTypeOfAccountDelegate {
    func updateTypeOfAccount(typeOfAccount: TypeOfAccount) {
        self.typeOfAccount = typeOfAccount
        self.typeOfAccountLabel.text = self.typeOfAccount.rawValue
        tableView.reloadData()
    }
}

//MARK: - UITextFieldDelegate method
extension InviteTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            emailTextField.resignFirstResponder()
            tapInviteButton()
        }
        return true
    }
}
