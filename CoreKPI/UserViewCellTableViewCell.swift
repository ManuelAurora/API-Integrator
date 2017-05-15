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
    @IBOutlet weak var memberProfilePhotoImage: CachedImageView!
    @IBOutlet weak var memberProfileNameLabel: UILabel!    
    @IBOutlet var buttons: [UIButton]!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func tapMailButton(_ sender: UIButton) {
        
        delegate.tapMailButton()       
    }
    
    @IBAction func tapPhoneButton(_ sender: UIButton) {
        
        delegate.tapPhoneButton()
    }
}
