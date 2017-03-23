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
            cell.inputDataTextField.becomeFirstResponder()
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
            _ = navigationController?.popToRootViewController(animated: true)
        }
    }    
}

//MARK: - UITextFieldDelegate method
extension AlertSelectSettingTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let originalString =  textField.text!
        var replacedString = ""
        
        // Deleting text
        if string.isEmpty {
            if originalString.isEmpty {
                textField.text = ""
                return false
            }
            replacedString = originalString.replacingOccurrences(of: ",", with: "")
            replacedString.remove(at: replacedString.index(before: replacedString.endIndex))
            
            if replacedString.contains(".") {
                
                if replacedString.hasSuffix(".") {
                    replacedString.remove(at: replacedString.index(before: replacedString.endIndex))
                    textFieldInputData = replacedString
                    textField.text = formatNumberFromString(stringNumber: replacedString) + "."
                    return false
                }
                
                if replacedString.hasSuffix("0") {
                    textFieldInputData = replacedString
                    return true
                }
            }
            textFieldInputData = replacedString
            textField.text = formatNumberFromString(stringNumber: replacedString)
            return false
            
        }
        
        //Check input symbols
        for number in string.characters {
            switch number {
            case "0"..."9", ".", ",":
                break
            default:
                return false
            }
        }
        // Adding text
        if originalString.isEmpty {
            if string == "," || string == "." {
                textField.text = "0."
                return false
            }
            replacedString = string.replacingOccurrences(of: ",", with: "")
            
            textFieldInputData = replacedString
            textField.text = formatNumberFromString(stringNumber: string)
            return false
            
        } else {
            
            if originalString.hasSuffix(".") {
                
                if string == "." || string == "," {
                    return false
                }
                
                if string == "0" {
                    return true
                }
                
                replacedString = originalString.replacingOccurrences(of: ",", with: "") + string.replacingOccurrences(of: ",", with: "")
                
                textFieldInputData = replacedString
                textField.text = formatNumberFromString(stringNumber: replacedString)
                
            }
            
            if string == "." {
                if originalString.contains(".") {
                    return false
                } else {
                    return true
                }
            }
            if string == "," {
                if originalString.contains(".") {
                    return false
                } else {
                    textField.text = originalString + "."
                    return false
                }
            }
            
            if originalString.contains(".") {
                var allZerro = true
                for number in string.characters {
                    if number != "0" {
                        allZerro = false
                    }
                }
                if allZerro {
                    return true
                }
            }
            
            replacedString = originalString.replacingOccurrences(of: ",", with: "") + string.replacingOccurrences(of: ",", with: "")
            
            textFieldInputData = replacedString
            textField.text = formatNumberFromString(stringNumber: replacedString)
            return false
        }
    }
    
    func formatNumberFromString(stringNumber: String) -> String {
        if stringNumber.isEmpty {
            return ""
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        // Replace any formatting commas
        let newStringNumber = stringNumber.replacingOccurrences(of: ",", with: "")
        
        let doubleFromString = Double(newStringNumber)
        
        let finalString = formatter.string(from: NSNumber(value: doubleFromString!))
        return finalString!
    }
    
}
