//
//  AddReportTableViewController.swift
//  CoreKPI
//
//  Created by Семен Осипов on 08.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

extension Double {
    func toInt() -> Int? {
        if self > Double(Int.min) && self < Double(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
}

class AddReportTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var numberOfCharactersLabel: UILabel!
    @IBOutlet weak var reportTextField: UITextField!
    
    var report: Double?
    var numberOfCharacters = 0
    let maxNumberOfCharacter = 20
    
    var formatter: NumberFormatter!
    
    weak var ReportAndViewVC: ReportAndViewKPITableViewController!
    var delegate: updateSettingsDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = maxNumberOfCharacter
        
        tableView.tableFooterView = UIView(frame: .zero)
        if report != nil {
            var reportString = formatNumberFromString(stringNumber: "\(report!)")
            reportTextField.text = reportString
            
            reportString = reportString.replacingOccurrences(of: ",", with: "")
            self.numberOfCharacters = reportString.replacingOccurrences(of: ".", with: "").characters.count
            numberOfCharactersLabel.text = "\(maxNumberOfCharacter - numberOfCharacters)"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Add report"
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Helvetica Neue", size: 13)
        header.textLabel?.textColor = UIColor.lightGray
    }
    
    @IBAction func tapSaveButton(_ sender: UIBarButtonItem) {
        
        if report == nil {
            self.showAlert(title: "Error", description: "Add report value!")
        } else {
            delegate = self.ReportAndViewVC
            delegate.updateDoubleValue(number: self.report)
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: - UITextFieldDelegate method
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let originalString =  textField.text!
        var replacedString: String!
        
        // Deleting text
        if string.isEmpty {
            if originalString.isEmpty {
                textField.text = ""
                self.numberOfCharacters = 0
                self.numberOfCharactersLabel.text = "\(maxNumberOfCharacter - numberOfCharacters)"
                return false
                
            }
            replacedString = originalString.replacingOccurrences(of: ",", with: "")
            replacedString.remove(at: replacedString.index(before: replacedString.endIndex))
            
            if replacedString.contains(".") {
                
                if replacedString.hasSuffix(".") {
                    replacedString.remove(at: replacedString.index(before: replacedString.endIndex))
                    self.report = Double(replacedString)
                    textField.text = formatNumberFromString(stringNumber: replacedString) + "."
                    return false
                }
                
                if replacedString.hasSuffix("0") {
                    self.report = Double(replacedString)
                    return true
                }
            }
            let numbersSize = replacedString.replacingOccurrences(of: ".", with: "").characters.count
            self.numberOfCharacters = numbersSize
            self.numberOfCharactersLabel.text = "\(maxNumberOfCharacter - numbersSize)"
            self.report = Double(replacedString)
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
            if string == "," || string == "." || string == "0" {
                textField.text = "0."
                self.numberOfCharacters += 1
                self.numberOfCharactersLabel.text = "\(maxNumberOfCharacter - numberOfCharacters)"
                return false
            }
            replacedString = string.replacingOccurrences(of: ",", with: "")
            let numbersSize = replacedString.replacingOccurrences(of: ".", with: "").characters.count
            
            if numbersSize > maxNumberOfCharacter {
                self.showAlert(title: "Warning", description: "So long number!")
                return false
            } else {
                self.numberOfCharacters = numbersSize
                self.numberOfCharactersLabel.text = "\(maxNumberOfCharacter - numberOfCharacters)"
                self.report = Double(replacedString)
                textField.text = formatNumberFromString(stringNumber: string)
                return false
            }
        } else {
            
            if originalString.hasSuffix(".") {
                
                if string == "." || string == "," {
                    return false
                }
                
                if string == "0" {
                    return true
                }
                
                replacedString = originalString.replacingOccurrences(of: ",", with: "") + string.replacingOccurrences(of: ",", with: "")
                let numbersSize = replacedString.replacingOccurrences(of: ".", with: "").characters.count
                if numbersSize > maxNumberOfCharacter {
                    self.showAlert(title: "Warning", description: "So long number!")
                    return false
                } else {
                    self.report = Double(replacedString)
                    self.numberOfCharacters = numbersSize
                    self.numberOfCharactersLabel.text = "\(maxNumberOfCharacter - numberOfCharacters)"
                    textField.text = formatNumberFromString(stringNumber: replacedString)
                }
            }
            
            if string == "." {
                if originalString.contains(".") {
                    return false
                } else {
                    return true
                }
            }
            if string == "," {
                textField.text = originalString + "."
                return false
            }
            
            if originalString.contains(".") {
                var allZerro = true
                for number in string.characters {
                    if number != "0" {
                        allZerro = false
                    }
                }
                if allZerro {
                    numberOfCharacters += string.characters.count
                    self.numberOfCharactersLabel.text = "\(maxNumberOfCharacter - numberOfCharacters)"
                    return true
                }
            }
            
            replacedString = originalString.replacingOccurrences(of: ",", with: "") + string.replacingOccurrences(of: ",", with: "")
            let numbersSize = replacedString.replacingOccurrences(of: ".", with: "").characters.count
            
            if numbersSize > maxNumberOfCharacter {
                self.showAlert(title: "Warning", description: "So long number!")
                return false
            } else {
                self.report = Double(replacedString)
                self.numberOfCharacters = numbersSize
                self.numberOfCharactersLabel.text = "\(maxNumberOfCharacter - numberOfCharacters)"
                textField.text = formatNumberFromString(stringNumber: replacedString)
                return false
            }
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.report = nil
        return true
    }
    
    func formatNumberFromString(stringNumber: String) -> String {
        if stringNumber.isEmpty {
            return ""
        }
        
        // Replace any formatting commas
        let newStringNumber = stringNumber.replacingOccurrences(of: ",", with: "")
        
        let doubleFromString = Double(newStringNumber)
        
        let finalString = formatter.string(from: NSNumber(value: doubleFromString!))
        return finalString!
    }
    
    //MARK: - Show alert
    func showAlert(title: String, description: String) {
        let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}


