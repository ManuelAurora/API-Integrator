//
//  HubspotRequestedObjects.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 07.03.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation


struct HSContact
{
    var contactId: Int!      // Contacts may have multiple vids, but the canonical-vid will be the primary ID for a record.
    var secondId: Int!       // The internal ID of the contact record.
    var mergedIds: [Int]!    // A list of vids that have been merged into this contact record.
    var portalId: Int!       // The Portal ID (Hub ID) that the record belongs to.
    var isContact: Bool!     // Indicates if the record is a valid contact record.
    var profileToken: String! //A unique token that can be used to view the contact without logging into HubSpot. See the profile-url below.
    var profileUrl: String!
    var createDate: Date! //The internal API name of the contact property
    var ownerId: Int! //Contact owner
    var assignDate: Date! //Date in wich owner was assigned
    var lastContactDate: Date! //Last contact date
    
    init(json:[String: Any]) {
        
        let properties = json["properties"] as! [String: Any]
        
        if let createDate = properties["createdate"] as? [String: Any], let timestampString = createDate["value"] as? String
        {
            if let timestamp = Double(timestampString) { self.createDate = Date(timeIntervalSince1970: timestamp / 1000) }
        }
        
        if let ownerAssignedDate = properties["hubspot_owner_assigneddate"] as? [String: Any], let timestampString = ownerAssignedDate["value"] as? String
        {
            if let timestamp = Double(timestampString) { assignDate = Date(timeIntervalSince1970: timestamp / 1000) }
        }
        
        if let lastContactedDate = properties["notes_last_contacted"] as? [String: Any], let timestampString = lastContactedDate["value"] as? String
        {
            if let timestamp = Double(timestampString) { lastContactDate = Date(timeIntervalSince1970: timestamp / 1000) }
        }
        
        if let ownerId = properties["hubspot_owner_id"] as? [String: Any], let valueString = ownerId["value"] as? String
        {
            if let value = Int(valueString) { self.ownerId = value }
        }
        
        contactId = json["canonical-vid"] as? Int
        secondId = json["vid"] as? Int
        portalId = json["portal-id"] as? Int
        isContact = json["is-contact"] as? Bool
        profileToken = json["profile-token"] as? String
        profileUrl = json["profile-url"] as? String        
    }
    
}

struct HSDeal
{
    var portalId: Int!
    var dealId: Int!
    var isDeleted: Bool!
    var closeDate: Date!
    var source: String!
    var sourceID: String!
    var amount: Int!
    var createDate: Date!
    
    init(json: [String: Any]) {
        
        let properties = json["properties"] as! [String: Any]
                
        if let createDate = properties["createdate"] as? [String: Any], let createDateTimestamp = createDate["timestamp"] as? Double
        {
            self.createDate = Date(timeIntervalSince1970: createDateTimestamp / 1000)
        }
        
        if let closeDateValue = properties["closedate"] as? [String: Any], let closeDate = closeDateValue["timestamp"] as? Double
        {
            self.closeDate = Date(timeIntervalSince1970: closeDate / 1000)
            source = closeDateValue["source"] as? String
            sourceID = closeDateValue["sourceId"] as? String
        }
        
        portalId = json["portalId"] as? Int
        dealId = json["dealId"] as? Int
        isDeleted = json["isDeleted"] as? Bool
        
        if let amountDict = properties["amount"] as? [String: Any], let amount = amountDict["value"] as? String
        {
            self.amount = Int(amount)
        }
    }
}
