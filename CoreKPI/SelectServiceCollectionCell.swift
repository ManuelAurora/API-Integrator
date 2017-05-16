//
//  SelectServiceCollectionCell.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 16.05.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class ServiceCell: UICollectionViewCell
{
    @IBOutlet weak var imageView: UIImageView!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        setupView()
    }
    
    private let titleLabel: UILabel = {
        let title = "Custom KPI"
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textAlignment = .center
        label.text = title
        return label
    }()
    
    private func setupView() {
        
        layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        backgroundColor = OurColors.lightBlue
    }
    
    func showCustomKPICell() {
        
        imageView.image = nil
        
        addSubview(titleLabel)
        titleLabel.textAlignment = .center
        titleLabel.anchor(self.topAnchor,
                          left: self.leftAnchor,
                          bottom: self.bottomAnchor,
                          right: self.rightAnchor,
                          topConstant: 0,
                          leftConstant: 0,
                          bottomConstant: 0,
                          rightConstant: 0,
                          widthConstant: 0,
                          heightConstant: self.frame.height / 2)
    }
    
    func setImageFor(service: IntegratedServices) {
        
        switch service
        {
        case .Quickbooks:       imageView.image = #imageLiteral(resourceName: "QuickBooks")
        case .GoogleAnalytics:  imageView.image = #imageLiteral(resourceName: "GoogleAnalytics")
        case .HubSpotCRM:       imageView.image = #imageLiteral(resourceName: "HubSpotCRM")
        case .HubSpotMarketing: imageView.image = #imageLiteral(resourceName: "HubSpotMarketing")
        case .PayPal:           imageView.image = #imageLiteral(resourceName: "PayPal")
        case .SalesForce:       imageView.image = #imageLiteral(resourceName: "SaleForce")
        default: break
        }
    }
}
