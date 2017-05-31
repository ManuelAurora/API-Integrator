//
//  AlertsListTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 23.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

enum TypeOfDigit: String {
    case Alert = "Alert"
    case Reminder = "Reminder"
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
    case OnlyWorksHours
    case TypeOfNotification
}

enum AlertTimeInterval: String {
    case Daily
    case Weekly
    case Monthly
      
    var prettyPrinted: String {
        return rawValue
    }
    
    var periodNameForServer: String {
        return rawValue
    }
}

enum Condition: String {
    case IsLessThan = "Is less than"
    case IsGreaterThan = "Is greater than"
    case DecreasedByMoreThan = "Decreased by more than"
    case IncreasedByMoreThan = "Increased by more than"
    case IncreasedOrDecreasedByMoreThan = "Increased or decreased  by more than"
    case PercentHasDecreasedByMoreThan = "% has decreased by more than"
    case PercentHasIncreasedByMoreThan = "% has increased by more than"
    case PercentHasIncreasedOrDecreasedByMoreThan = "% has increased or decreased by more than"
}

enum TypeOfNotification: String {
    case none
    case SMS
    case Push
    case Email
}

class AlertsListTableViewController: UITableViewController {
    
    var model: ModelCoreKPI!
    let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.contentOffset = CGPoint(x: 0, y: 0 - self.tableView.contentInset.top)
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.clear
        refreshControl?.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        refreshControl?.endRefreshing()
        refreshControl?.removeFromSuperview()
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.showsVerticalScrollIndicator = true 
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 0/255.0, green: 151.0/255.0, blue: 167.0/255.0, alpha: 1.0)]
        
        let nc = NotificationCenter.default
        
        nc.addObserver(self,
                       selector: #selector(AlertsListTableViewController.catchNotification(notification:)),
                       name: .modelDidChanged,
                       object: nil)
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
        
        loadReminders()
        loadAlerts()
    }
        
    override func tableView(_ tableView: UITableView,
                            editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .default,
                                                title: "Delete",
                                                handler: {
                                                    (action, indexPath) in
                                                    self.deleteButtonDidTaped(
                                                        indexPath: indexPath)
        })
        return [deleteAction]
    }
        
    //MARK: - CatchNotification
    func catchNotification(notification:Notification) -> Void {
        
        if notification.name == .modelDidChanged {
            tableView.reloadData()
        }
    }
    
    //MARK: -  Pull to refresh method
    func refresh(sender:AnyObject)
    {
        loadReminders()
        loadAlerts()
    }
    
    //MARK: - Load Alerts from server
    func loadAlerts() {
        let request = GetAlerts(model: model)
        request.getAlerts(success: { alerts in
            
            for alert in self.model.alerts {
                self.context.delete(alert)
            }
            self.model.alerts.removeAll()
            self.model.alerts = alerts
            do {
                try self.context.save()
            } catch {
                print(error)
                return
            }
            
            let sectionIndex = IndexSet(integer: 1)
            self.tableView.reloadSections(sectionIndex, with: .automatic)
            
            self.refreshControl?.endRefreshing()
        }, failure: { error in
            self.showAlert(title: "Error Occured", message: error)
            self.refreshControl?.endRefreshing()
        }
        )
    }
    
    //MARK: - Load Reminders from server
    func loadReminders() {
        let request = GetReminders(model: model)
        request.getReminders(success: { reminders in
            
            for reminder in self.model.reminders {
                self.context.delete(reminder)
            }
            self.model.reminders.removeAll()
            self.model.reminders = reminders
            do {
                try self.context.save()
            } catch {
                print(error)
                return
            }
            
            let sectionIndex = IndexSet(integer: 0)
            self.tableView.reloadSections(sectionIndex, with: .automatic)
            
            self.refreshControl?.endRefreshing()
        }, failure: { error in
            self.showAlert(title: "Error Occured", message: error)
            self.refreshControl?.endRefreshing()
        }
        )
        
    }
    
    //MARK: - Show alert controller
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return model.reminders.count
        case 1:
            return model.alerts.count
        default:
            break
        }
        return model.alerts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlertsCell", for: indexPath) as! AlertsListTableViewCell
        cell.AlertListVC = self
        
        switch indexPath.section {
        case 0:
            let alertText = model.getNameKPI(
                FromID: Int(model.reminders[indexPath.row].sourceID))
            
            cell.alertNameLabel.text = alertText ?? "Deleted reminder's KPI"
            cell.editButton.isHidden = alertText == nil ? true : false 
            cell.numberOfCell = indexPath.row
            cell.alertImageView.layer.backgroundColor = model.getBackgroundColourOfKPI(FromID: model.reminders[indexPath.row].sourceID).cgColor
            cell.editButton.tag = indexPath.row
            
        case 1:
            cell.alertNameLabel.text = model.getNameKPI(FromID: Int(model.alerts[indexPath.row].sourceID)) ?? "Deleted alert's KPI"
            cell.numberOfCell = indexPath.row + (model.reminders.count - 1)
            cell.alertImageView.layer.backgroundColor = model.getBackgroundColourOfKPI(FromID: model.alerts[indexPath.row].sourceID).cgColor
            cell.editButton.tag = indexPath.row + (model.reminders.count)
        default:
            break
        }
        return cell
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddAlert" {
            let destinationVC = segue.destination as! AlertSettingsTableViewController
            destinationVC.model = model
            destinationVC.AlertListVC = self
            destinationVC.creationMode = .createNew
            destinationVC.typeOfDigit = .Alert
        }
        if segue.identifier == "ReminderView" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! ReminderViewTableViewController
                destinationController.typeOfDigit = indexPath.section == 0 ? .Reminder : .Alert
                destinationController.index = indexPath.row
                destinationController.model = model
                destinationController.AlertListVC = self
            }
        }
    }
}

//MARK: - AlertButtonCellDelegate method
extension AlertsListTableViewController
{
    func deleteButtonDidTaped(indexPath: IndexPath) {
        
        switch indexPath.section
        {
        case 0:
            //it is reminders
            let request = DeleteReminder(model: model)
            let reminderId =  Int(model.reminders[indexPath.row].reminderID)
            model.reminders.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .top)
            request.deleteReminder(reminderID: reminderId, success: {
            }, failure: { error in
                self.showAlert(title: "Error Occured", message: error)
                self.loadReminders()
            })
            
        default:
            //it is alerts
            let request = DeleteAlert(model: model)
            let alertID = Int(model.alerts[indexPath.row].alertID)
            request.deleteAlert(alertID: alertID, success: {
                self.model.alerts.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .top)
            }, failure: { error in
                self.showAlert(title: "Error Occured", message: error)
                self.loadAlerts()
            }
            )
        }
    }
}
