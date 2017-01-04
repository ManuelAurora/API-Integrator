//
//  AlertsListTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 23.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class AlertsListTableViewController: UITableViewController {

    struct Alert {
        var name: String
        var image: String
    }

    var model = ModelCoreKPI(token: "123", profile: Profile(userId: 1, userName: "user@mail.ru", firstName: "user", lastName: "user", position: "CEO", photo: nil, phone: nil, nickname: nil, typeOfAccount: .Admin))//: ModelCoreKPI!
    var alertsList: [Alert]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alertOne = Alert(name: "My Shop Sales", image: "")
        let alertTwo = Alert(name: "My Shop Supples", image: "")
        alertsList = [alertOne, alertTwo]
        
        tableView.tableFooterView = UIView(frame: .zero)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alertsList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlertsCell", for: indexPath) as! AlertsListTableViewCell
       cell.alertNameLabel.text = alertsList[indexPath.row].name
        
        return cell
    }

}
