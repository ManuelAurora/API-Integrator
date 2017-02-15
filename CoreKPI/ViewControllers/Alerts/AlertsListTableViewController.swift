//
//  AlertsListTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 23.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

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

enum TimeInterval: String {
    case Daily
    case Weekly
    case Monthly
}

enum Condition: String {
    case IsLessThan = "is less than"
    case IsGreaterThan = "is greater than"
    case DecreasedByMoreThan = "decreased by more than"
    case IncreasedByMoreThan = "increased by more than"
    case IncreasedOrDecreasedByMoreThan = "increased or decreased  by more than"
    case PercentHasDecreasedByMoreThan = "% has decreased by more than"
    case PercentHasIncreasedByMoreThan = "% has increased by more than"
    case PercentHasIncreasedOrDecreasedByMoreThan = "% has increased or decreased by more than"
}

enum TypeOfNotification: String {
    case none
    case SMS
    case Push = "Push notification"
    case Email
}

class AlertsListTableViewController: UITableViewController {
    
    var model: ModelCoreKPI!
    let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
    let modelDidChangeNotification = Notification.Name(rawValue:"modelDidChange")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 0/255.0, green: 151.0/255.0, blue: 167.0/255.0, alpha: 1.0)]
        
        let nc = NotificationCenter.default
        nc.addObserver(forName:modelDidChangeNotification, object:nil, queue:nil, using:catchNotification)
        
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.clear
        refreshControl?.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
        test()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadAlerts()
    }
    
    func test() {
        let alertOne = Alert(context: context)
        alertOne.sourceID = 13
        alertOne.pushNotificationIsActive = true
        alertOne.backgroundColor = "Green"
        alertOne.condition = "is less than"
        alertOne.deliveryDay = 5
        alertOne.deliveryTime = Date(timeIntervalSinceNow: 600) as NSDate?
        alertOne.onlyWorkHours = true
        alertOne.threshold = 140.45
        alertOne.timeInterval = "Daily"
        alertOne.timeZone = "Pacific Time (PST)"
        model.alerts.append(alertOne)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - CatchNotification
    func catchNotification(notification:Notification) -> Void {
        
        if notification.name == modelDidChangeNotification {
            guard let userInfo = notification.userInfo,
                let model = userInfo["model"] as? ModelCoreKPI else {
                    print("No userInfo found in notification")
                    return
            }
            self.model.alerts = model.alerts
            self.model.kpis = model.kpis
            tableView.reloadData()
        }
    }
    
    //MARK: -  Pull to refresh method
    func refresh(sender:AnyObject)
    {
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
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }, failure: { error in
            self.showAlert(title: "Sorry", message: error)
            self.refreshControl?.endRefreshing()
        }
        )
    }
    
    //MARK: - Show alert
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.alerts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlertsCell", for: indexPath) as! AlertsListTableViewCell
        
        cell.alertNameLabel.text = model.getNameKPI(FromID: Int(model.alerts[indexPath.row].sourceID))
        cell.numberOfCell = indexPath.row
        cell.alertImageView.layer.backgroundColor = UIColor.green.cgColor //Debug
        cell.deleteButton.tag = indexPath.row
        cell.AlertListVC = self
        
        return cell
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddAlert" {
            let destinationVC = segue.destination as! AlertSettingsTableViewController
            destinationVC.model = ModelCoreKPI(model: self.model)
            destinationVC.AlertListVC = self
        }
        if segue.identifier == "ReminderView" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! ReminderViewTableViewController
                destinationController.index = indexPath.row
                destinationController.model = ModelCoreKPI(model: model)
                destinationController.AlertListVC = self
            }
        }
    }
    
}


//MARK: - AlertButtonCellDelegate method
extension AlertsListTableViewController: AlertButtonCellDelegate {
    
    func deleteButtonDidTaped(sender: UIButton) {
        var newAlertList: [Alert] = []
        for i in 0..<model.alerts.count {
            if i != sender.tag {
                newAlertList.append(model.alerts[i])
            }
        }
        self.model.alerts = newAlertList
        tableView.reloadData()
    }
}
