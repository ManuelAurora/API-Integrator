//
//  AddReportTableViewController.swift
//  CoreKPI
//
//  Created by Семен Осипов on 08.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class AddReportTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var numberOfCharactersLabel: UILabel!
    @IBOutlet weak var reportTextField: UITextField!
    
    var report: Double?
    var numberOfCharacters = 0
    
    weak var ReportAndViewVC: ReportAndViewKPITableViewController!
    var delegate: updateSettingsDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        if report != nil {
            if ceil(report!) == floor(report!) && "\(report)".characters.count < 17 {
                let string = "\(report!)".components(separatedBy: ".")[0]
                reportTextField.text = string
            } else {
                reportTextField.text = "\(self.report!)"
            }
            numberOfCharactersLabel.text = "\(20 - (reportTextField.text?.characters.count)!)"
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
        
        let reportString = reportTextField.text?.replacingOccurrences(of: ",", with: ".")
        
        if let number = Int(numberOfCharactersLabel.text!), let rep  = Double(reportString!) {
            if number >= 0 {
                self.report = rep
                delegate = self.ReportAndViewVC
                delegate.updateDoubleValue(number: self.report)
                _ = navigationController?.popViewController(animated: true)
            } else {
                showAlert(title: "Error", description: "So long number")
            }
        } else {
            showAlert(title: "Error", description: "Input data incorrect")
        }
        
    }
    
    //MARK: - UITextFieldDelegate method
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        
        if txtAfterUpdate == "" {
            self.report = nil
            self.numberOfCharacters = 0
        }
        if txtAfterUpdate.characters.count > 20 {
            return false
        }
        var numbersCount = 0
        for symbol in txtAfterUpdate.characters {
            switch symbol {
            case "0"..."9":
                numbersCount += 1
            case ".", ",":
                break
            case "e", "+", "-":
                break
            default:
                showAlert(title: "Error", description: "Data incorect")
                return false
            }
        }
        self.numberOfCharacters = numbersCount
        self.numberOfCharactersLabel.text = "\(20 - self.numberOfCharacters)"
        return true
    }
    
    //MARK: - Show alert
    func showAlert(title: String, description: String) {
        let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}


