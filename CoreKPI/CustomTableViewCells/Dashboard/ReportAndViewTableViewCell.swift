//
//  ReportAndViewTableViewCell.swift
//  CoreKPI
//
//  Created by Семен Осипов on 08.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class ReportAndViewTableViewCell: UITableViewCell {

    @IBOutlet weak var headerOfCell: UILabel!
    @IBOutlet weak var descriptionOfCell: UILabel!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
