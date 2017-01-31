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
    var delegate: UpdateTimeDelegate!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
         delegate = addKPIVC// ?? editKPIVC
    }
    @IBAction func dataPickerDidMove(_ sender: UIDatePicker) {
        delegate.updateTime(newTime: datePicker.date)
    }

}
