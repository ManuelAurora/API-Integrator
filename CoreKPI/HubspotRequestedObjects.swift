//
//  HubspotRequestedObjects.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 07.03.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation


class HSDeal
{
    var portalId: Int!
    var dealId: Int!
    var isDeleted: Bool!
    var closeDate: Date!
    var source: String!
    var sourseID: String!
    var amount: Int!
    
    init() { }
    
    convenience init(json: [String: Any]) {
        self.init()
        
        let properties = json["properties"] as! [String: Any]
        let closeDateValue = properties["closedate"] as? [String: Any]
        
        portalId = json["portalId"] as! Int
        dealId = json["dealId"] as! Int
        isDeleted = json["isDeleted"] as! Bool
        
        if let closeDate = closeDateValue
        {
            self.closeDate = Date(timeIntervalSince1970: Double(closeDate["timestamp"] as! Int))
            source = properties["sourceId"] as? String
            sourseID = properties["sourceId"] as? String
        }
        
        if let amountDict = properties["amount"] as? [String: Any], let amount = amountDict["value"] as? String
        {
            self.amount = Int(amount)
        }
    }
}
