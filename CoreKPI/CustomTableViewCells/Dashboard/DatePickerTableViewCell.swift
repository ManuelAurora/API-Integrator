//
//  DatePickerTableViewCell.swift
//  CoreKPI
//
//  Created by Семен on 31.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class DatePickerTableViewCell: UITableViewCell {

    var addKPIVC: ChooseSuggestedKPITableViewController!
    var editKPIVC: ReportAndViewKPITableViewController!
    var alertSettingVC: AlertSettingsTableViewController!
    
    var delegate: UpdateTimeDelegate!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if addKPIVC != nil {
            delegate = addKPIVC
        }
        if editKPIVC != nil {
            delegate = editKPIVC
        }
        if alertSettingVC != nil {
            delegate = alertSettingVC
        }
        
    }
    @IBAction func dataPickerDidMove(_ sender: UIDatePicker) {
        delegate.updateTime(newTime: datePicker.date)
    }

}
