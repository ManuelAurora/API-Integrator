//
//  DashboardSetingTableViewCell.swift
//  CoreKPI
//
//  Created by Семен on 27.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class DashboardSetingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerOfCell: UILabel!
    @IBOutlet weak var descriptionOfCell: UILabel!
    @IBOutlet weak var trailingToRightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
