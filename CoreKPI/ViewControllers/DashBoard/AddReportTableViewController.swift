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
    
    var kpiArray: [KPI] = []
    var kpiIndex: Int!
    var report: Int?
    weak var KPIListVC: KPIsListTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        var newCreated = kpiArray[kpiIndex].createdKPI
        newCreated?.addReport(report: report!)
        kpiArray[kpiIndex].createdKPI = newCreated
        let delegate: updateKPIListDelegate = self.KPIListVC
        delegate.updateKPIList(kpiArray: self.kpiArray)
        let kpiListViewController = self.navigationController?.viewControllers[0]
        _ = self.navigationController?.popToViewController(kpiListViewController!, animated: true)
    }

    //MARK: - UITextFieldDelegate method
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        
        if txtAfterUpdate == "" {
            self.report = nil
        } else {
//            guard self.report = Int(txtAfterUpdate) else {
//                let alertController = UIAlertController(title: "Error", message: "Data incorect", preferredStyle: .alert)
//                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self.present(alertController, animated: true, completion: nil)
//            }
        }
        
        self.numberOfCharactersLabel.text = "\(140 - txtAfterUpdate.characters.count)"
        return true
    }
    
}
