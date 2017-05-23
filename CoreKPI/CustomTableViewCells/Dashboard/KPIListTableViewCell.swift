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
   
    private var optionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Some Text"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .lightGray
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private func layoutViews() {
        
        self.addSubview(optionsLabel)
        optionsLabel.anchor(KPIListHeaderLabel.bottomAnchor,
                            left: KPIListHeaderLabel.leftAnchor,
                            bottom: bottomAnchor,
                            right: KPIListHeaderLabel.rightAnchor,
                            topConstant: -30,
                            leftConstant: 0,
                            bottomConstant: 0,
                            rightConstant: 0,
                            widthConstant: 0,
                            heightConstant: 0)
    }    
    
    func showOptionsValue(for kpi: KPI) {
        
        guard kpi.integratedKPI != nil else {
            optionsLabel.removeFromSuperview()
            return
        }
        
        var labelText = "Default text"
        
        layoutViews()
        
        if let pipelineId = kpi.integratedKPI.hsPipelineID
        {
            if let pipeLabel = kpi.integratedKPI.hsPipelineLabel
            {
                labelText = pipeLabel
            }
            else
            {
                labelText = pipelineId
            }
        }
        else if let gaSiteUrl = kpi.integratedKPI.googleAnalyticsKPI?.siteURL
        {
            labelText = gaSiteUrl
        }
        else if let qbRealmId = kpi.integratedKPI.quickbooksKPI?.realmId
        {
            labelText = qbRealmId
        }
        else if let sfInstanceUrl = kpi.integratedKPI.saleForceKPI?.instance_url
        {
            labelText = sfInstanceUrl
        }
        else
        {
            optionsLabel.removeFromSuperview()
            return
        }
        
        optionsLabel.text = labelText        
    }
    
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
