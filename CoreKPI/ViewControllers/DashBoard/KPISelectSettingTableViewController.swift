//
//  KPISelectSettingTableViewController.swift
//  CoreKPI
//
//  Created by Семен Осипов on 07.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class KPISelectSettingTableViewController: UITableViewController {
    
    weak var ReportAndViewVC: ReportAndViewKPITableViewController!
    var ChoseSuggestedVC: ChooseSuggestedKPITableViewController!
    var selectSetting: [(SettingName: String, value: Bool)]!
    var textFieldInputData: String?
    weak var delegate: updateSettingsDelegate!
    
    var integratedService = IntegratedServices.none
    var headerForTableView: String!
    var selectSeveralEnable = false
    var inputSettingCells = false
    var rowsWithInfoAccesory = false
    var segueWithSelecting = false
    var cellsWithColourView = false
    var shoulUseCustomAnimation = false
    var department = Departments.none
    
    var colourDictionary: [Colour : UIColor] = [:]
    
    deinit {
        print("DEBUG: KPISelectSettingVC deinitialized")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        navigationController!.delegate = delegate
        
        tableView.tableFooterView = UIView(frame: .zero)        
        tableView.alwaysBounceVertical = rowsWithInfoAccesory ? true : false
        
        if selectSetting.isEmpty {
            let alertVC = UIAlertController(title: "Sorry!", message: "No Data for select",
                                            preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                (action: UIAlertAction!) -> Void in
                self.navigationController?.popViewController(animated: true)
            }))
        }
        
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if inputSettingCells == true { return 1 }
        else { return self.selectSetting.count }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if inputSettingCells == true { return headerForTableView }
        else { return " " }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Helvetica Neue", size: 13)
        header.textLabel?.textColor = UIColor.lightGray
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: .listOfSuggestedKPIVC) as! SuggestedKPIDescriptionTableViewController
        destinatioVC.numberOfKPI = indexPath.row
        destinatioVC.ChoseSuggestedVC = ChoseSuggestedVC
        destinatioVC.department = department
        destinatioVC.selectSetting = selectSetting
        navigationController?.pushViewController(destinatioVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let selectCell = tableView.dequeueReusableCell(withIdentifier: "SelectSettingCell", for: indexPath)
        let inputCell = tableView.dequeueReusableCell(withIdentifier: "InputSettingCell", for: indexPath) as! KPISettingInputTableViewCell
        let colourCell = tableView.dequeueReusableCell(withIdentifier: "ColourCell", for: indexPath) as! KPIColourTableViewCell
        
        if rowsWithInfoAccesory {
            selectCell.textLabel?.text = selectSetting[indexPath.row].SettingName
            selectCell.accessoryType = .detailButton
            selectCell.textLabel?.numberOfLines = 0
            selectCell.prepareForReuse()
            return selectCell
        }
        if inputSettingCells == true {
            inputCell.inputTextView.becomeFirstResponder()
            if (textFieldInputData != nil) {
                inputCell.inputTextView.text = textFieldInputData
            }
            inputCell.accessoryType = .none
            inputCell.selectionStyle = .none
            inputCell.prepareForReuse()
            return inputCell
        }
        if cellsWithColourView == true {
            let colour = selectSetting[indexPath.row].SettingName
            colourCell.headerOfCell.text = colour
            if let uicolour = colourDictionary[Colour(rawValue: colour)!] {
                colourCell.colourView.backgroundColor = uicolour
            }
            colourCell.accessoryType = selectSetting[indexPath.row].value ? .checkmark : .none
            colourCell.prepareForReuse()
            return colourCell
        }
        selectCell.textLabel?.text = selectSetting[indexPath.row].SettingName
        selectCell.accessoryType = selectSetting[indexPath.row].value ? .checkmark : .none
        selectCell.prepareForReuse()
        return selectCell
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
        
        if rowsWithInfoAccesory || segueWithSelecting {
            shoulUseCustomAnimation = tableView.visibleCells.count == 2 ? true : false 
            navigationController?.popViewController(animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    //MARK: - Send data to parent ViewController
    override func willMove(toParentViewController parent: UIViewController?) {
        if(!(parent?.isEqual(self.parent) ?? false)) {
            if ChoseSuggestedVC != nil {
                let choosenValue = (selectSetting.filter { $0.value == true })[0]
                textFieldInputData = choosenValue.SettingName
                delegate = ChoseSuggestedVC
                delegate.updateSettingsArray(array: selectSetting)
                delegate.updateStringValue(string: textFieldInputData)
            }
            if ReportAndViewVC != nil {
                delegate = ReportAndViewVC
                delegate.updateSettingsArray(array: selectSetting)
                delegate.updateStringValue(string: textFieldInputData)
            }
        }
    }
    
    @IBAction func tapSaveButton(_ sender: UIBarButtonItem) {
        ChoseSuggestedVC.integrated = integratedService
        delegate = ChoseSuggestedVC
        delegate.updateSettingsArray(array: selectSetting)
        
        let ChoseSuggestVC = self.navigationController?.viewControllers[1] as! ChooseSuggestedKPITableViewController
        _ = self.navigationController?.popToViewController(ChoseSuggestVC, animated: true)
    }
}

//MARK: - UITextFieldDelegate method
extension KPISelectSettingTableViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            textFieldInputData = nil
        } else {
            textFieldInputData = textView.text
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            navigationController?.popViewController(animated: true)
            return false
        }
        return true
    }
}

