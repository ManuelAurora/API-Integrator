//
//  AlertsListTableViewCell.swift
//  CoreKPI
//
//  Created by Семен on 23.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class AlertsListTableViewCell: UITableViewCell {

    var numberOfCell: Int!
    var deleteDidTaped = false
    
    var AlertListVC: AlertsListTableViewController!
    var delegate: AlertButtonCellDelegate!
    
    @IBOutlet weak var alertNameLabel: UILabel!
    @IBOutlet weak var alertImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func tapDeleteButton(_ sender: UIButton) {
        self.delegate = self.AlertListVC
        delegate.deleteButtonDidTaped(sender: deleteButton)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
