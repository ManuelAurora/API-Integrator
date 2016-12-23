//
//  KPIListTableViewCell.swift
//  CoreKPI
//
//  Created by Семен on 23.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class KPIListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var KPIListCellImageView: UIImageView!
    @IBOutlet weak var KPIListManagedBy: UILabel!
    @IBOutlet weak var KPIListHeaderLabel: UILabel!
    @IBOutlet weak var KPIListNumber: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
