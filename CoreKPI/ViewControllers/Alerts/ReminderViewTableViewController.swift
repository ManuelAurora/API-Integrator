////
//  ReminderViewTableViewController.swift
//  CoreKPI
//
//  Created by Семен Осипов on 06.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class ReminderViewTableViewController: UITableViewController {

    var model: ModelCoreKPI!
    var index: Int!
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
            for kpi in model.kpis {
                let alertID = model.alerts[index].sourceID
                if kpi.id == Int(alertID) && kpi.createdKPI?.executant != model.profile?.userId {
                    return 3
                }
            }
            if model.alerts[index].timeInterval == TimeInterval.Daily.rawValue {
                return 3
            } else {
                return 4
            }
        case 1:
            var rows = 0
            if model.alerts[index].emailNotificationIsActive {
                rows += 1
            }
            if model.alerts[index].pushNotificationIsActive {
                rows += 1
            }
            if model.alerts[index].smsNotificationIsAcive {
                rows += 1
            }
            return rows
        default:
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderViewCell", for: indexPath)
        
        switch indexPath.section {
        case 0:
            for kpi in model.kpis {
                let alertID = model.alerts[index].sourceID
                if kpi.id == Int(alertID) && kpi.createdKPI?.executant != model.profile?.userId {
                    switch indexPath.row {
                    case 0:
                        cell.textLabel?.text = "Condition - " + (model.alerts[index].condition)!
                    case 1:
                        cell.textLabel?.text = "Threshold " + "\(model.alerts[index].threshold)" + (model.alerts[index].condition == Condition.PercentHasIncreasedOrDecreasedByMoreThan.rawValue ? "%" : "")
                    case 2:
                        cell.textLabel?.text = "Delivery at " + (model.alerts[index].onlyWorkHours ? "work hours" : "Alltime")
                    default:
                        break
                    }
                }
            }
            if model.alerts[index].timeInterval == TimeInterval.Daily.rawValue {
                switch indexPath.row {
                case 0:
                    cell.textLabel?.text = model.alerts[index].timeInterval
                case 1:
                    cell.textLabel?.text = "Time zone: " + model.alerts[index].timeZone!
                case 2:
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeStyle = .short
                    cell.textLabel?.text = "Delivery at " + dateFormatter.string(from: model.alerts[index].deliveryTime as! Date)
                default:
                    break
                }

            } else {
                switch indexPath.row {
                case 0:
                    cell.textLabel?.text = model.alerts[index].timeInterval
                case 1:
                    cell.textLabel?.text = "Day: \(model.alerts[index].deliveryDay)"
                case 2:
                    cell.textLabel?.text = "Time zone: " + model.alerts[index].timeZone!
                case 3:
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeStyle = .short
                    cell.textLabel?.text = "Delivery at " + dateFormatter.string(from: model.alerts[index].deliveryTime as! Date)
                default:
                    break
                }

            }
        case 1:
            switch indexPath.row {
            case 0:
                if model.alerts[index].emailNotificationIsActive {
                    cell.textLabel?.text = "Email"
                } else {
                    fallthrough
                }
            case 1:
                if model.alerts[index].smsNotificationIsAcive {
                    cell.textLabel?.text = "SMS"
                } else {
                    fallthrough
                }
            case 2:
                if model.alerts[index].pushNotificationIsActive {
                    cell.textLabel?.text = "Email"
                } else {
                    break
                }
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
            return model.getNameKPI(FromID: Int(model.alerts[index].sourceID))
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
            destinationVC.model = ModelCoreKPI(model: model)
            destinationVC.ReminderViewVC = self
            destinationVC.updateParameters(index: index)
        }
    }
}
