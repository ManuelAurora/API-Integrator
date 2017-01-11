//
//  KPIDescriptionTableViewCell.swift
//  CoreKPI
//
//  Created by Семен on 10.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class KPIDescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var headerOfCellLabel: UILabel!
    @IBOutlet weak var descriptionOfCellLabel: UILabel!
    @IBOutlet weak var kpiInfoTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
