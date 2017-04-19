//
//  AddReportTableViewController.swift
//  CoreKPI
//
//  Created by Семен Осипов on 08.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class AddReportTableViewController: UITableViewController {
    
    @IBOutlet weak var numberOfCharactersLabel: UILabel!
    @IBOutlet weak var reportTextField: UITextField!
    
    var report: Double?
    var numberOfCharacters = 0
    let maxNumberOfCharacter = 15
    
    var formatter: NumberFormatter!
    
    weak var ReportAndViewVC: ReportAndViewKPITableViewController!
    var delegate: updateSettingsDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reportTextField.becomeFirstResponder()
        
        formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = maxNumberOfCharacter
        
        numberOfCharactersLabel.text = "\(maxNumberOfCharacter)"
        
        tableView.tableFooterView = UIView(frame: .zero)
        if report != nil {
            var reportString = formatNumberFromString(stringNumber: "\(report!)")
            reportTextField.text = reportString
            
            reportString = reportString.replacingOccurrences(of: ",", with: "")
            self.numberOfCharacters = reportString.replacingOccurrences(of: ".", with: "").characters.count
            numberOfCharactersLabel.text = "\(maxNumberOfCharacter - numberOfCharacters)"
        }
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
            showAlert(title: "Error", errorMessage: "Add report value!")
        } else {
            delegate = ReportAndViewVC
            delegate.updateDoubleValue(number: report)
            
            _ = navigationController?.popViewController(animated: true)
        }
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
}

extension AddReportTableViewController: UITextFieldDelegate {
    //MARK: - UITextFieldDelegate method
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let originalString =  textField.text!
        var replacedString: String!
        
        // Deleting text
        if string.isEmpty {
            if originalString.isEmpty {
                textField.text = ""
                numberOfCharacters = 0
                numberOfCharactersLabel.text = "\(maxNumberOfCharacter - numberOfCharacters)"
                return false
                
            }
            replacedString = originalString.replacingOccurrences(of: ",", with: "")
            replacedString.remove(at: replacedString.index(before: replacedString.endIndex))
            
            if replacedString.contains(".") {
                
                if replacedString.hasSuffix(".") {
                    replacedString.remove(at: replacedString.index(before: replacedString.endIndex))
                    report = Double(replacedString)
                    textField.text = formatNumberFromString(stringNumber: replacedString) + "."
                    return false
                }
                
                if replacedString.hasSuffix("0") {
                    report = Double(replacedString)
                    return true
                }
            }
            let numbersSize = replacedString.replacingOccurrences(of: ".", with: "").characters.count
            numberOfCharacters = numbersSize
            numberOfCharactersLabel.text = "\(maxNumberOfCharacter - numbersSize)"
            report = Double(replacedString)
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
                numberOfCharacters += 1
                numberOfCharactersLabel.text = "\(maxNumberOfCharacter - numberOfCharacters)"
                return false
            }
            replacedString = string.replacingOccurrences(of: ",", with: "")
            let numbersSize = replacedString.replacingOccurrences(of: ".", with: "").characters.count
            
            if numbersSize > maxNumberOfCharacter {
                showAlert(title: "Warning", errorMessage: "So long number!")
                return false
            } else {
                numberOfCharacters = numbersSize
                numberOfCharactersLabel.text = "\(maxNumberOfCharacter - numberOfCharacters)"
                report = Double(replacedString)
                textField.text = formatNumberFromString(stringNumber: string)
                return false
            }
        } else {
            
            if originalString.hasSuffix(".") {
                
                if string == "." || string == "," {
                    return false
                }
                
                if string == "0" {
                    if numberOfCharacters < maxNumberOfCharacter {
                        numberOfCharacters += 1
                        numberOfCharactersLabel.text = "\(maxNumberOfCharacter-numberOfCharacters)"
                        return true
                    } else {
                        showAlert(title: "Warning", errorMessage: "So long number!")
                        return false
                    }
                    
                }
                
                replacedString = originalString.replacingOccurrences(of: ",", with: "") + string.replacingOccurrences(of: ",", with: "")
                let numbersSize = replacedString.replacingOccurrences(of: ".", with: "").characters.count
                if numbersSize > maxNumberOfCharacter {
                    showAlert(title: "Warning", errorMessage: "So long number!")
                    return false
                } else {
                    report = Double(replacedString)
                    numberOfCharacters = numbersSize
                    numberOfCharactersLabel.text = "\(maxNumberOfCharacter - numberOfCharacters)"
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
                    
                    if numberOfCharacters + string.characters.count <= maxNumberOfCharacter {
                        numberOfCharacters += string.characters.count
                        numberOfCharactersLabel.text = "\(maxNumberOfCharacter - numberOfCharacters)"
                        return true
                    } else {
                        showAlert(title: "Warning", errorMessage: "So long number!")
                        return false
                    }
                }
            }
            
            replacedString = originalString.replacingOccurrences(of: ",", with: "") + string.replacingOccurrences(of: ",", with: "")
            let numbersSize = replacedString.replacingOccurrences(of: ".", with: "").characters.count
            
            if numbersSize > maxNumberOfCharacter {
                showAlert(title: "Warning", errorMessage: "So long number!")
                return false
            } else {
                report = Double(replacedString)
                numberOfCharacters = numbersSize
                numberOfCharactersLabel.text = "\(maxNumberOfCharacter - numberOfCharacters)"
                textField.text = formatNumberFromString(stringNumber: replacedString)
                return false
            }
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        report = nil
        numberOfCharacters = 0
        numberOfCharactersLabel.text = "\(maxNumberOfCharacter - numberOfCharacters)"
        return true
    }

}

