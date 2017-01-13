//
//  faqListTableViewCell.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class faqListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var numberBackgroundView: UIView!
    @IBOutlet weak var numberOfQuestionLabel: UILabel!
    @IBOutlet weak var headerOfQuestionLabel: UILabel!
    @IBOutlet weak var describeOfQuestionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
