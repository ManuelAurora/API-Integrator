//
//  ChartTableViewCell.swift
//  CoreKPI
//
//  Created by Семен on 18.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class ChartTableViewCell: UITableViewCell {

    @IBOutlet weak var metricsLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var persentLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
