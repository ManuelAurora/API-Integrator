//
//  AlertsListTableViewCell.swift
//  CoreKPI
//
//  Created by Семен on 23.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class  AlertsListTableViewCell: UITableViewCell {

    var numberOfCell: Int!
    var deleteDidTaped = false
    
    var AlertListVC: AlertsListTableViewController!
    var delegate: AlertButtonCellDelegate!
    
    @IBOutlet weak var alertNameLabel: UILabel!
    @IBOutlet weak var alertImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func tapEditButton(_ sender: UIButton) {
        
        let model = ModelCoreKPI.modelShared
        let indexPath = AlertListVC.tableView.indexPath(for: self)!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: .alertSettingsTableVC) as! AlertSettingsTableViewController
        
        var dataSource: Int64 = 0
        
        if indexPath.section == 0
        {
            dataSource = model.reminders[indexPath.row].reminderID
        }
        else
        {
            dataSource = model.alerts[indexPath.row].alertID
        }
        
        destinationVC.dataSource = NSNumber(value: dataSource).intValue
        destinationVC.AlertListVC = AlertListVC
        destinationVC.model = model
        destinationVC.creationMode = .edit
        
        if indexPath.section == 0
        {
            destinationVC.typeOfDigit = .Reminder
            destinationVC.updateParameters(index: indexPath.row)
        }
        else
        {
            destinationVC.typeOfDigit = .Alert
            destinationVC.updateParameters(index: indexPath.row)
        }
        
        AlertListVC.navigationController?.pushViewController(destinationVC,
                                                             animated: true)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
