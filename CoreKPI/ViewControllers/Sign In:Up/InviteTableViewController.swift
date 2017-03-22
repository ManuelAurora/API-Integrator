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
    
    var stateMachine = UserStateMachine.shared
    var model: ModelCoreKPI!
    var invitePerson: Profile!
    var typeOfAccount = TypeOfAccount.Manager
    var numberOfInvations = 0
    var email: String?
    var password: String?
    
    @IBAction func laterButtonTapped(_ sender: UIBarButtonItem) {
        
        guard let email = email, let password = password else { return }
        
        stateMachine.logInWith(email: email, password: password)
    }
    
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
            showAlert(title: "Error", errorMessage: "You haven't more invitations!")
            return
        }
        if emailTextField.text == "" {
            showAlert(title: "Error", errorMessage: "Field(s) are empty!")
            return
        }
        
        if !validate(email: emailTextField.text!, password: nil)
        {
            showAlert(title: "Error occured", errorMessage: "Invalid E-mail adress")
        }
        
        let alertController = UIAlertController(title: "Send invitation", message: "We’ll send an invitation to \(emailTextField.text!)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Send", style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.sendInvations()
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addInvites(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Need more invitations?", message: "You more invitations left. Would you like to buy more?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Buy", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            self.getNewSubscribe()
        }))
        alertController.addAction(UIAlertAction(title: "No thanks", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
        
    }
    
    //MARK: - Function for send invations on server
    func sendInvations() {
        
        let emailLowercased = emailTextField.text?.lowercased()
        let inviteRequest = SendInvation(model: model)
        
        inviteRequest.sendInvations(email: emailLowercased!, typeOfAccount: typeOfAccount, success: {number in
            self.showAlert(title: "Congratulation!", errorMessage: "You send invitation to \(self.emailTextField.text!)")
            self.emailTextField.text = ""
            self.numberOfInvations = number
            self.numberOfInvationsLAbel.text = "\(self.numberOfInvations) invitations left"
            self.typeOfAccount = .Manager
            self.typeOfAccountLabel.text = self.typeOfAccount.rawValue
            self.tableView.reloadData()
        }, failure: { error in
            self.showAlert(title: "Error occured", errorMessage: error)
        })
    }
    
    //MARK: - prepare for navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "TypeOfNewAccount"
        {
            let destinationViewController = segue.destination as! TypeOfAccountTableViewController
            destinationViewController.typeOfAccount = self.typeOfAccount
            destinationViewController.InviteVC = self
        }
    }
    
    //MARK: - get number of invations from server
    private func getNumberOfInvations() {
        
        let request = GetNumberOfInvations(model: model)
        request.getNumberOfInvations(success: { number in
            self.numberOfInvations = number
            self.numberOfInvationsLAbel.text = "\(self.numberOfInvations) invitations left"
        }, failure: { error in
            self.showAlert(title: "Sorry!", errorMessage: error)
        })
    }
    
    //MARK: - buying subscribe
    private func getNewSubscribe() {
        print("Add buying in ")
        //TODO: add byuing InviteTableViewController
    }
    
}

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
