//
//  KPISelectSettingTableViewController.swift
//  CoreKPI
//
//  Created by Семен Осипов on 07.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class KPISelectSettingTableViewController: UITableViewController, UITextViewDelegate {
    
    weak var ChoseSuggestedVC: ChooseSuggestedKPITableViewController!
    var selectSetting: [(SettingName: String, value: Bool)]!
    var textFieldInputData: String?
    var delegate: updateSettingsDelegate!
    
    var integratedService = IntegratedServices.none
    var headerForTableView: String!
    var selectSeveralEnable = false
    var inputSettingCells = false
    var rowsWithInfoAccesory = false
    var department = Departments.none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        
        if rowsWithInfoAccesory {
            self.tableView.alwaysBounceVertical = true
        } else {
            self.tableView.alwaysBounceVertical = false
        }
        
        tableView.autoresizesSubviews = true
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
            return self.selectSetting.count
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
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: "ListOfSuggestedKPI") as! SuggestedKPIDescriptionTableViewController
        destinatioVC.numberOfKPI = indexPath.row
        destinatioVC.ChoseSuggestedVC = self.ChoseSuggestedVC
        destinatioVC.department = self.department
        destinatioVC.selectSetting = self.selectSetting
        navigationController?.pushViewController(destinatioVC, animated: true)

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch rowsWithInfoAccesory {
        case true:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectSettingCell", for: indexPath)
            
            cell.textLabel?.text = selectSetting[indexPath.row].SettingName
            cell.accessoryType = .detailButton
            cell.textLabel?.numberOfLines = 0
            return cell
        default:
            if inputSettingCells == false {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectSettingCell", for: indexPath)
                
                cell.textLabel?.text = selectSetting[indexPath.row].SettingName
                cell.accessoryType = selectSetting[indexPath.row].value ? .checkmark : .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "InputSettingCell", for: indexPath) as! KPISettingInputTableViewCell
                if (self.textFieldInputData != nil) {
                    cell.inputTextView.text = self.textFieldInputData
                }
                cell.accessoryType = .none
                cell.selectionStyle = .none
                return cell
            }
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
        
        if rowsWithInfoAccesory {
            self.navigationController!.popViewController(animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //MARK: - Send data to parent ViewController
    override func willMove(toParentViewController parent: UIViewController?) {
        if(!(parent?.isEqual(self.parent) ?? false)) {
            delegate = ChoseSuggestedVC
            delegate.updateSettingsArray(array: selectSetting)
            delegate.updateStringValue(string: self.textFieldInputData)
        }
    }
    
    @IBAction func tapSaveButton(_ sender: UIBarButtonItem) {
        self.ChoseSuggestedVC.integrated = self.integratedService
        delegate = ChoseSuggestedVC
        delegate.updateSettingsArray(array: self.selectSetting)
        
        let ChoseSuggestVC = self.navigationController?.viewControllers[1] as! ChooseSuggestedKPITableViewController
        _ = self.navigationController?.popToViewController(ChoseSuggestVC, animated: true)
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        self.textFieldInputData = textView.text
        
    }
}
