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
    
    var typeOfDigit: TypeOfDigit = .Reminder
    
    weak var AlertListVC: AlertsListTableViewController!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch typeOfDigit {
        case .Alert:
            navigationItem.title = "Alert view"
        case .Reminder:
            navigationItem.title = "Reminder view"
        }
        
        let nc = NotificationCenter.default
        nc.addObserver(forName: .modelDidChanged, object:nil, queue:nil, using:catchNotification)
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
        
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            switch typeOfDigit {
            case .Alert:
                return 3
            case .Reminder:
                if model.reminders[index].timeInterval == AlertTimeInterval.Daily.rawValue {
                    return 3
                } else {
                    return 4
                }
            }
        case 1:
            var rows = 0
            switch typeOfDigit {
            case .Alert:
                if model.alerts[index].emailNotificationIsActive {
                    rows += 1
                }
                if model.alerts[index].pushNotificationIsActive {
                    rows += 1
                }
                if model.alerts[index].smsNotificationIsAcive {
                    rows += 1
                }
            case .Reminder:
                if model.reminders[index].emailNotificationIsActive {
                    rows += 1
                }
                if model.reminders[index].pushNotificationIsActive {
                    rows += 1
                }
                if model.reminders[index].smsNotificationIsActive {
                    rows += 1
                }
            }
            return rows
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderViewCell", for: indexPath)
        
        switch indexPath.section
        {
        case 0:            
            switch typeOfDigit {
            case .Alert:
                switch indexPath.row {
                case 0:
                    cell.textLabel?.text = "Condition - " + (model.alerts[index].condition)!
                case 1:
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = .decimal
                    let thresholdNumber = model.alerts[index].threshold as NSNumber
                    let thresholdString = numberFormatter.string(from: thresholdNumber)
                    
                    var persentEnabled = false
                    
                    switch (Condition(rawValue: model.alerts[index].condition!))! {
                    case .PercentHasDecreasedByMoreThan, .PercentHasIncreasedByMoreThan, .PercentHasIncreasedOrDecreasedByMoreThan:
                        persentEnabled = true
                    default:
                        break
                    }
                
                    cell.textLabel?.text = "Threshold " + "\(thresholdString!)" + (persentEnabled ? "%" : "")
                case 2:
                    cell.textLabel?.text = "Delivery at " + (model.alerts[index].onlyWorkHours ? "work hours" : "Alltime")
                default:
                    break
                }
            case .Reminder:
                if model.reminders[index].timeInterval == AlertTimeInterval.Daily.rawValue {
                    switch indexPath.row {
                    case 0:
                        cell.textLabel?.text = model.reminders[index].timeInterval
                    case 1:
                        cell.textLabel?.text = "Time zone: " + model.reminders[index].timeZone!
                    case 2:
                        let dateFormatter = DateFormatter()
                        dateFormatter.timeStyle = .short
                        cell.textLabel?.text = "Delivery at " + dateFormatter.string(from: model.reminders[index].deliveryTime! as Date)
                    default:
                        break
                    }
                } else {
                    switch indexPath.row {
                    case 0:
                        cell.textLabel?.text = model.reminders[index].timeInterval
                    case 1:
                        cell.textLabel?.text = "Day: \(model.reminders[index].deliveryDay)"
                    case 2:
                        cell.textLabel?.text = "Time zone: " + model.reminders[index].timeZone!
                    case 3:
                        let dateFormatter = DateFormatter()
                        dateFormatter.timeStyle = .short
                        cell.textLabel?.text = "Delivery at " + dateFormatter.string(from: model.reminders[index].deliveryTime! as Date)
                    default:
                        break
                    }
                }
            }
        case 1:
            switch typeOfDigit {
            case .Alert:
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
                        cell.textLabel?.text = "Push"
                    } else {
                        break
                    }
                default:
                    break
                }
            case .Reminder:
                switch indexPath.row {
                case 0:
                    if model.reminders[index].emailNotificationIsActive {
                        cell.textLabel?.text = "Email"
                    } else {
                        fallthrough
                    }
                case 1:
                    if model.reminders[index].smsNotificationIsActive {
                        cell.textLabel?.text = "SMS"
                    } else {
                        fallthrough
                    }
                case 2:
                    if model.reminders[index].pushNotificationIsActive {
                        cell.textLabel?.text = "Push"
                    } else {
                        break
                    }
                default:
                    break
                }
            }
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            switch typeOfDigit {
            case .Alert:
                return model.getNameKPI(FromID: Int(model.alerts[index].sourceID))
            case .Reminder:
                return model.getNameKPI(FromID: Int(model.reminders[index].sourceID))
            }
            
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
            let destinationVC = segue.destination as! AlertSettingsTableViewController
            destinationVC.model = model
            destinationVC.ReminderViewVC = self
            destinationVC.typeOfDigit = typeOfDigit
            destinationVC.creationMode = .edit
            destinationVC.updateParameters(index: index)
        }
    }
    
    //MARK: - catchNotification
    func catchNotification(notification:Notification) -> Void {
        
        if notification.name == .modelDidChanged {            
            _ = navigationController?.popToRootViewController(animated: true)
        }
    }
}
