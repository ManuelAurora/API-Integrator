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
    @IBOutlet weak var ManagedByStack: UIStackView!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var viewButton: UIButton!
   
    var KPIListVC: KPIsListTableViewController!
    var delegate: KPIListButtonCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func buttonDidTaped(_ sender: UIButton) {
        self.delegate = KPIListVC
        switch sender {
        case editButton:
            delegate.editButtonDidTaped(sender: sender)
        case reportButton:
            delegate.reportButtonDidTaped(sender: sender)
        case viewButton:
            delegate.viewButtonDidTaped(sender: sender)
        default:
            break
        }
    }

}
