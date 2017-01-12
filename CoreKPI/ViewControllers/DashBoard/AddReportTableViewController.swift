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
    weak var ReportAndViewVC: ReportAndViewKPITableViewController!
    var delegate: updateSettingsDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        if report != nil {
            reportTextField.text = "\(report!)"
            numberOfCharactersLabel.text = "\(140 - (reportTextField.text?.characters.count)!)"
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
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Add report"
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Helvetica Neue", size: 13)
        header.textLabel?.textColor = UIColor.lightGray
    }
    
    @IBAction func tapAddReportButton(_ sender: UIButton) {
        
        if let number = Int(numberOfCharactersLabel.text!) {
            if number >= 0 {
                delegate = self.ReportAndViewVC
                delegate.updateDoubleValue(number: self.report)
                _ = navigationController?.popViewController(animated: true)
            } else {
                showAlert(title: "Error", description: "So long number")
            }
        }
    }
    
    //MARK: - UITextFieldDelegate method
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        
        if txtAfterUpdate == "" {
            self.report = nil
        } else {
            
            if let number = Double(txtAfterUpdate) {
                self.report = number
            } else {
                showAlert(title: "Error", description: "Data incorect")
            }
        }
        self.numberOfCharactersLabel.text = "\(140 - txtAfterUpdate.characters.count)"
        return true
    }
    
    //MARK: - Show alert
    func showAlert(title: String, description: String) {
        let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}


