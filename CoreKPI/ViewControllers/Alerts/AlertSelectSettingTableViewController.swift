//
//  AlertSelectSettingTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 27.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class AlertSelectSettingTableViewController: UITableViewController {
    
    weak var AlertSettingVC: AlertSettingsTableViewController!
    let modelDidChangeNotification = Notification.Name(rawValue:"modelDidChange")
    
    var selectSetting: [(SettingName: String, value: Bool)]!
    var textFieldInputData: String?
    var delegate: updateSettingsDelegate!
    
    var headerForTableView: String!
    var selectSeveralEnable = false
    var inputSettingCells = false
    var segueWithSelect = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if selectSetting.isEmpty {
            let alertVC = UIAlertController(title: "Sorry!", message: "No Data for select", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) -> Void in
                _ = self.navigationController?.popViewController(animated: true)
            }
            ))
            present(alertVC, animated: true, completion: nil)
        }
        let nc = NotificationCenter.default
        nc.addObserver(forName: modelDidChangeNotification, object:nil, queue:nil, using:catchNotification)
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
        if inputSettingCells == true {
            return 1
        } else {
            return selectSetting.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if inputSettingCells == true {
            return headerForTableView
        } else {
            return " "
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Helvetica Neue", size: 13)
        header.textLabel?.textColor = UIColor.lightGray
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if inputSettingCells == false {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectSettingCell", for: indexPath)
            
            cell.textLabel?.text = selectSetting[indexPath.row].SettingName
            cell.accessoryType = selectSetting[indexPath.row].value ? .checkmark : .none
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InputSettingCell", for: indexPath) as! AlertInputSettingTableViewCell
            if textFieldInputData != nil {
                cell.inputDataTextField.text = textFieldInputData
            }
            cell.inputDataTextField.placeholder = "Add data"
            cell.accessoryType = .none
            cell.selectionStyle = .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if inputSettingCells == true {
            return
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectSettingCell", for: indexPath)
        
        if selectSeveralEnable == false {
            for i in 0..<selectSetting.count {
                selectSetting[i].value = false
            }
        }
        
        if selectSetting[indexPath.row].value == false {
            selectSetting[indexPath.row].value = true
            cell.accessoryType = .checkmark
        } else {
            selectSetting[indexPath.row].value = false
            cell.accessoryType = .none
        }
        
        if segueWithSelect == true {
            let _ = navigationController?.popViewController(animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    //MARK: - Send data to parent ViewController
    override func willMove(toParentViewController parent: UIViewController?) {
        if(!(parent?.isEqual(self.parent) ?? false)) {
            
            delegate = AlertSettingVC
            
            if inputSettingCells {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                if textFieldInputData != nil    {
                    if let double: Double = formatter.number(from: textFieldInputData!) as Double? {
                        delegate.updateDoubleValue(number: double)
                    } else {
                        let alertVC = UIAlertController(title: "Error", message: "Data is incorrect", preferredStyle: .alert)
                        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        present(alertVC, animated: true, completion: nil)
                    }
                }
            }
            delegate.updateSettingsArray(array: selectSetting)
        }
    }
    //MARK: - catchNotification
    func catchNotification(notification:Notification) -> Void {
        
        if notification.name == modelDidChangeNotification {
            guard let userInfo = notification.userInfo,
                let _ = userInfo["model"] as? ModelCoreKPI else {
                    print("No userInfo found in notification")
                    return
            }
            let firstVC = navigationController?.viewControllers[0]
            _ = navigationController?.popToViewController(firstVC!, animated: true)
        }
    }
    
}

//MARK: - UITextFieldDelegate method
extension AlertSelectSettingTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        
        if txtAfterUpdate == "" {
            textFieldInputData = nil
            return true
        }
        
        switch string {
        case "0"..."9", ".", "":
            textFieldInputData = txtAfterUpdate
            return true
        case ",":
            textField.text = (textFieldText as String) + "."
            textFieldInputData = txtAfterUpdate
            return false
        default:
            return false
        }
    }
}
