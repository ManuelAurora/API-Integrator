//
//  SuggestedKPIDescriptionTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 27.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class SuggestedKPIDescriptionTableViewController: UITableViewController {
    
    var delegate: updateSettingsDelegate!
    weak var ChoseSuggestedVC: ChooseSuggestedKPITableViewController!
    var numberOfKPI: Int!
    
    var department = Departments.none
    var buildInKPI: BuildInKPI!
    
    var kpiArray: [String] = []
    var kpiDescriptionArray: [String] = []
    
     var selectSetting: [(SettingName: String, value: Bool)]!
    
    @IBOutlet weak var kpiDescriptionTextView: UITextView!
    @IBOutlet weak var kpiNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildInKPI = BuildInKPI(department: self.department)
        self.updateKPIArray()
        self.updateSettingArray()
        
        kpiNameLabel.text = kpiArray[numberOfKPI]
        kpiDescriptionTextView.text = kpiDescriptionArray[numberOfKPI]
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - updateSettingArray method
    func updateSettingArray() {
        for i in 0..<selectSetting.count {
            self.selectSetting[i].value = false
            if self.numberOfKPI == i {
                self.selectSetting[i].value = true
            }
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Helvetica Neue", size: 13)
        header.textLabel?.textColor = UIColor.lightGray
    }
    
    //MARK: - updateKPIArray method
    func updateKPIArray() {
        self.kpiArray.removeAll()
        self.kpiDescriptionArray.removeAll()
        
        var dictionary: [String:String] = [:]
        
        switch department {
        case .none:
            return
        case .Sales:
            dictionary = buildInKPI.salesDictionary
        case .Procurement:
            dictionary = buildInKPI.procurementDictionary
        case .Projects:
            dictionary = buildInKPI.projectDictionary
        case .FinancialManagement:
            dictionary = buildInKPI.financialManagementDictionary
        case .Staff:
            dictionary = buildInKPI.staffDictionary
        }
        for kpi in dictionary {
            self.kpiArray.append(kpi.key)
            self.kpiDescriptionArray.append(kpi.value)
        }
    }
    
    @IBAction func tapSelectButton(_ sender: UIBarButtonItem) {
        delegate = ChoseSuggestedVC
        delegate.updateSettingsArray(array: selectSetting)
        let vc = self.navigationController?.viewControllers[1] as! ChooseSuggestedKPITableViewController
        _ = self.navigationController?.popToViewController(vc, animated: true)
    }
    
}
