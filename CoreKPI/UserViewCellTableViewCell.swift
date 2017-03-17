//
//  UserViewCellTableViewCell.swift
//  CoreKPI
//
//  Created by Мануэль on 01.03.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class UserViewTableViewCell: UITableViewCell
{
    weak var delegate: MemberInfoViewController!
    
    @IBOutlet weak var memberProfilePositionLabel: UILabel!
    @IBOutlet weak var memberProfilePhotoImage: UIImageView!
    @IBOutlet weak var memberProfileNameLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func tapMailButton(_ sender: UIButton) {
        
        delegate.tapMailButton()       
    }
    
    @IBAction func tapPhoneButton(_ sender: UIButton) {
        
        delegate.tapPhoneButton()
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
