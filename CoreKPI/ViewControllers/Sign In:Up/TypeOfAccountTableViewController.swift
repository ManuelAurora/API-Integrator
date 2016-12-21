//
//  TypeOfAccountTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 16.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class TypeOfAccountTableViewController: UITableViewController {

    var typeOfAccount: TypeOfAccount!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TypeAccount", for: indexPath) as! TypeAccountTableViewCell

        switch indexPath.row {
        case 0:
            cell.typeAccountLabel.text = "Admin"
            typeOfAccount == TypeOfAccount.Admin ? (cell.accessoryType = .checkmark) : (cell.accessoryType = .none)
        case 1:
            cell.typeAccountLabel.text = "Manager"
            typeOfAccount == TypeOfAccount.Manager ? (cell.accessoryType = .checkmark) : (cell.accessoryType = .none)
        default:
            cell.typeAccountLabel.text = ""
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TypeAccount", for: indexPath)
        
        switch indexPath.row {
        case 0:
            typeOfAccount = TypeOfAccount.Admin
            cell.accessoryType = .checkmark
        case 1:
            typeOfAccount = TypeOfAccount.Manager
            cell.accessoryType = .checkmark
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        
    }

}
