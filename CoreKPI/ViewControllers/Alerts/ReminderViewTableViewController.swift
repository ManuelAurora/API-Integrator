//
//  ReminderViewTableViewController.swift
//  CoreKPI
//
//  Created by Семен Осипов on 06.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class ReminderViewTableViewController: UITableViewController, updateAlertListDelegate {
    
    var alert: Alert!
    weak var AlertListVC: AlertsListTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        switch section {
        case 0:
            if alert.timeInterval == .Daily || alert.dataSource == .Balance {
                return 3
            } else {
                return 4
            }
        case 1:
            return alert.typeOfNotification.count
        default:
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderViewCell", for: indexPath)
        
        switch indexPath.section {
        case 0:
            
            switch alert.dataSource {
            case .Balance:
                switch indexPath.row {
                case 0:
                    cell.textLabel?.text = "Condition - " + (alert.condition?.rawValue)!
                case 1:
                    cell.textLabel?.text = "Threshold " + alert.threshold! + (alert.condition == Condition.PercentHasIncreasedOrDecreasedByMoreThan ? "%" : "")
                case 2:
                    cell.textLabel?.text = "Delivery at " + alert.deliveryTime
                default:
                    break
                }
            default:
                if alert.timeInterval == .Daily {
                    switch indexPath.row {
                    case 0:
                        cell.textLabel?.text = alert.timeInterval?.rawValue
                    case 1:
                        cell.textLabel?.text = "Time zone: " + alert.timeZone!
                    case 2:
                        cell.textLabel?.text = "Delivery at " + alert.deliveryTime
                    default:
                        break
                    }
                } else {
                    switch indexPath.row {
                    case 0:
                        cell.textLabel?.text = alert.timeInterval?.rawValue
                    case 1:
                        cell.textLabel?.text = "Day: " + alert.deliveryDay!
                    case 2:
                        cell.textLabel?.text = "Time zone: " + alert.timeZone!
                    case 3:
                        cell.textLabel?.text = "Delivery at " + alert.deliveryTime
                    default:
                        break
                    }
                }
            }
        case 1:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = alert.typeOfNotification[0].rawValue
            case 1:
                cell.textLabel?.text = alert.typeOfNotification[1].rawValue
            case 2:
                cell.textLabel?.text = alert.typeOfNotification[2].rawValue
            default:
                break
            }
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return alert.dataSource.rawValue
        case 1:
            return "Type of notification"
        default:
            return " "
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Helvetica Neue", size: 13)
        header.textLabel?.textColor = UIColor.lightGray
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditReminder" {
            let destinationVC = segue.destination as! AllertSettingsTableViewController
            destinationVC.ReminderViewVC = self
            destinationVC.updateParameters(alert: self.alert)
        }
    }
    
    //MARK: - updateAlertListDelegate method
    func addAlert(alert: Alert) {
        self.alert = alert
        tableView.reloadData()
    }
    
}
