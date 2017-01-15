//
//  AlertsListTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 23.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

struct Alert {
    var image: String
    var dataSource: DataSource
    var timeInterval: TimeInterval?
    var deliveryDay: String?
    var timeZone: String?
    var condition: Condition?
    var threshold: String?
    var deliveryTime: String//Date
    var typeOfNotification: [TypeOfNotification]
}

enum Setting: String {
    case none
    case DataSource
    case TimeInterval
    case DeliveryDay
    case TimeZone
    case Condition
    case Threshold
    case DeliveryTime
    case TypeOfNotification
}

enum TimeInterval: String {
    case Daily
    case Weekly
    case Monthly
}

enum DataSource: String {
    case MyShopSupples = "My shop supples"
    case MyShopSales = "My shop sales"
    case Balance
}

enum Condition: String {
    case IsLessThan = "is less than"
    case IncreasedOrDecreased = "increased or decreased"
    case PercentHasIncreasedOrDecreasedByMoreThan = "% has increased or decreased by more than"
}

enum TypeOfNotification: String {
    case none
    case SMS
    case Push = "Push notification"
    case Email
}

class AlertsListTableViewController: UITableViewController, updateAlertListDelegate, AlertButtonCellDelegate {

    var model = ModelCoreKPI(token: "123", profile: Profile(userId: 1, userName: "user@mail.ru", firstName: "user", lastName: "user", position: "CEO", photo: nil, phone: nil, nickname: nil, typeOfAccount: .Admin))//: ModelCoreKPI!
    var alertsList: [Alert]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alertOne = Alert(image: "", dataSource: .MyShopSales, timeInterval: .Daily, deliveryDay: nil, timeZone: "+3", condition: nil, threshold: nil, deliveryTime: "18:00", typeOfNotification: [.Push])
        let alertTwo = Alert(image: "", dataSource: .MyShopSupples, timeInterval: .Daily, deliveryDay: nil, timeZone: "+3", condition: nil, threshold: nil, deliveryTime: "18:00", typeOfNotification: [.SMS])
        alertsList = [alertOne, alertTwo]
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 0/255.0, green: 151.0/255.0, blue: 167.0/255.0, alpha: 1.0)]
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
        cell.alertNameLabel.text = alertsList[indexPath.row].dataSource.rawValue
        cell.numberOfCell = indexPath.row
        if indexPath.row % 2 == 0 {
            cell.alertImageView.layer.backgroundColor = UIColor(red: 251/255, green: 233/255, blue: 231/255, alpha: 1.0).cgColor
        } else {
            cell.alertImageView.layer.backgroundColor = UIColor(red: 216/255, green: 247/255, blue: 215/255, alpha: 1.0).cgColor
        }
        cell.deleteButton.tag = indexPath.row
        cell.AlertListVC = self
        return cell
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddAlert" {
            let destinationVC = segue.destination as! AllertSettingsTableViewController
            destinationVC.model = ModelCoreKPI(model: self.model)
            destinationVC.AlertListVC = self
        }
        if segue.identifier == "ReminderView" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! ReminderViewTableViewController
                destinationController.alert = self.alertsList[indexPath.row]
                destinationController.AlertListVC = self
            }
        }
    }
    
    func addAlert(alert: Alert) {
        self.alertsList.append(alert)
        tableView.reloadData()
    }

    func deleteButtonDidTaped(sender: UIButton) {
        var newAlertList: [Alert] = []
        for i in 0..<alertsList.count {
            if i != sender.tag {
                newAlertList.append(self.alertsList[i])
            }
        }
        self.alertsList = newAlertList
        tableView.reloadData()
    }
}
