//
//  MemberEditTableViewCell.swift
//  CoreKPI
//
//  Created by Семен on 22.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit
import PhoneNumberKit

class MemberEditTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerOfCell: UILabel!
    @IBOutlet weak var textFieldOfCell: UITextField!
    @IBOutlet weak var phoneNumberTextField: PhoneNumberTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
