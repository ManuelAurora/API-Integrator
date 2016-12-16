//
//  NewProfileViewController.swift
//  CoreKPI
//
//  Created by Семен on 15.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

enum TypeOfAccount: String {
    case Admin
    case Manager
}

class NewProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var newProfileTableView: UITableView!
    
    var typeOfAccout: TypeOfAccount!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 0/255.0, green: 151.0/255.0, blue: 167.0/255.0, alpha: 1.0)]
//        navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 0/255.0, green: 151.0/255.0, blue: 167.0/255.0, alpha: 1.0)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellInfo = tableView.dequeueReusableCell(withIdentifier: "NewProfile", for: indexPath) as! NewProfileInfoTableViewCell
        let cellTypeAccount = tableView.dequeueReusableCell(withIdentifier: "NewProfileTypeAccount", for: indexPath) as! NewProfileTypeAccountTableViewCell
        switch indexPath.row {
        case 0:
            cellInfo.newProfileTextField.placeholder = "First name"
        case 1:
            cellInfo.newProfileTextField.placeholder = "Last name"
        case 2:
            cellInfo.newProfileTextField.placeholder = "Position"
        case 3:
            cellTypeAccount.typeAccountLabel.text = ""
        default:
            cellInfo.newProfileTextField.placeholder = ""
        }
        if indexPath.row == 3 {
            return cellInfo
        } else {
            return cellTypeAccount
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TypeOfAccount" {
                let destinationController = segue.destination as! TypeOfAccountTableViewController
                //Настройка контроллера назначения
                destinationController.typeOfAccount = typeOfAccout
            
        }
    }
    
    
}
