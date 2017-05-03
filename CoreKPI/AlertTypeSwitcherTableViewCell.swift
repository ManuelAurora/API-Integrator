//
//  AlertTypeSwitcherTableViewCell.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 03.05.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class AlertTypeSwitcherTableViewCell: UITableViewCell
{

    @IBOutlet weak var alertTypeStepper: UISegmentedControl!
    weak var delegate: AlertSettingsTableViewController!
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
    
        if sender.selectedSegmentIndex == 0
        {
            delegate.setAlert(type: .Alert)
        }
        else
        {
            delegate.setAlert(type: .Reminder)
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        selectionStyle = .none
        setSettings()
    }
    
    func setSettings() {
        
        alertTypeStepper.tintColor = OurColors.cyan
    }
   

}
