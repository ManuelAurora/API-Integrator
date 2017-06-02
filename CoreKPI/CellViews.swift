//
//  CellViews.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 02.06.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

struct CustomCellView: CellView {}

extension CustomCellView
{
    func setup(cell: ServiceCell) {
        cell.showCustomKPICell()
    }
}

struct IntegratedCellView: CellView
{
    let service: IntegratedServices
    let isActive: Bool
    let intServicesPrepared: Bool
    
    var image: UIImage {
        switch service
        {
        case .Quickbooks:       return #imageLiteral(resourceName: "QuickBooks")
        case .GoogleAnalytics:  return #imageLiteral(resourceName: "GoogleAnalytics")
        case .HubSpotCRM:       return #imageLiteral(resourceName: "HubSpotCRM")
        case .HubSpotMarketing: return #imageLiteral(resourceName: "HubSpotMarketing")
        case .PayPal:           return #imageLiteral(resourceName: "PayPal")
        case .SalesForce:       return #imageLiteral(resourceName: "SaleForce")
        case .none: return UIImage()
        }
    }
}

extension IntegratedCellView
{
    func setup(cell: ServiceCell) {
        
        cell.imageView.image = image
        if !isActive { cell.grayOut() }
        if isActive && !intServicesPrepared
        {
            cell.animateWaitingForServer()
        }
        else if isActive
        {
            cell.removeGrayLayer()
        }
    }
}
