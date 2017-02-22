//
//  DataPickerTableViewCell.swift
//  CoreKPI
//
//  Created by Семен on 22.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class DataPickerTableViewCell: UITableViewCell {

    @IBOutlet weak var dataPicker: UIPickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
