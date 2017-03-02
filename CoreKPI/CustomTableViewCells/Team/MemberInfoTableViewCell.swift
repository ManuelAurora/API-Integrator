//
//  MemberInfoTableViewCell.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class MemberInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var headerCellLabel: UILabel!
    @IBOutlet weak var securitySwitch: UISwitch!
    @IBOutlet weak var dataCellLabel: UILabel!
    
    @IBAction func securutySwitchTapped(_ sender: UISwitch) {
        
        NotificationCenter.default.post(name: NSNotification.Name.userTappedSecuritySwitch, object: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
