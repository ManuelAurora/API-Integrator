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
    @IBOutlet weak var KPIListCellImageBacgroundView: UIView!
    
    @IBOutlet weak var KPIListHeaderLabel: UILabel!
    @IBOutlet weak var KPIListNumber: UILabel!
    @IBOutlet weak var ManagedByStack: UIStackView!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var memberNameButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
   
    var KPIListVC: KPIsListTableViewController!
    var delegate: KPIListButtonCellDelegate!
   
    
    @IBAction func buttonDidTaped(_ sender: UIButton) {
        
        self.delegate = KPIListVC
        
        switch sender
        {
        case editButton:
            delegate.userTapped(button: sender, edit: true)
            
        case reportButton:
            delegate.userTapped(button: sender, edit: false)
            
        case memberNameButton:
            delegate.memberNameDidTaped(sender: sender)
            
        case deleteButton:
            delegate.deleteDidTaped(sender: sender)
            
        default: break
        }
    }

}
