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

struct HSPipeline
{
    var pipelineId: String! //The internal ID of the pipeline
    var label: String!      //The human-readable label for the pipeline.
    var active: Bool!       //true for any pipeline currently in use.
    var displayOrder: Int!  //Used to determine the order in which the pipelines appear when viewed in HubSpot.
    
    var stages = [HSStage]()
    
    init(json: [String: Any]) {
        pipelineId = json["pipelineId"] as? String
        label = json["label"] as? String
        active = json["active"] as? Bool
        displayOrder = json["displayOrder"] as? Int
    }
}

struct HSStage
{
    var stageId: String!    //The stageId should be used when setting the dealstage property of a deal record.
    var label: String!      //The human-readable label for the stage. The label is used when showing the stage in HubSpot.
    var probability: Float! //The probability that the deal will close. Used for the deal forecast.
    var active: Bool!       //True for any stage that's currently in use.
    var displayOrder: Int!  //Used to determine the order in which the stages appear when viewed in HubSpot.
    var closedWon: Bool!    //True if this stage marks a deal as closed won.
    
    var deals = [HSDeal]()
    
    init(json: [String: Any]) {
        stageId = json["stageId"] as? String
        label = json["label"] as? String
        probability = json["probability"] as? Float
        active = json["active"] as? Bool
        displayOrder = json["displayOrder"] as? Int
        closedWon = json["closedWon"] as? Bool
    }
}

enum OwnerType: String
{
    case person = "PERSON"
    case queue = "QUEUE"
}

struct HSOwner
{
    var portalId: Int!
    var ownerId: Int!
    var type: OwnerType!
    var firstName: String!
    var lastName: String!
    var email: String!
    var createdAt: Date!
    var updatedAt: Date!
    
    var deals = [HSDeal]()
    
    func sum() -> Int {
        
        return deals.reduce(0, { sum, deal -> Int in
            sum + deal.amount
        })
    }
    
    init(json: [String: Any]) {
        
        if let typeString = json["type"] as? String
        {
            type = OwnerType(rawValue: typeString)
        }
        
        if let dateInt = json["createdAt"] as? Int
        {
            createdAt = Date(timeIntervalSince1970: Double(dateInt) / 1000)
        }
        
        if let dateInt = json["updatedAt"] as? Int
        {
            updatedAt = Date(timeIntervalSince1970: Double(dateInt) / 1000)
        }
        
        portalId = json["portalId"] as? Int
        ownerId = json["ownerId"] as? Int
        firstName = json["firstName"] as? String
        lastName = json["lastName"] as? String
        email = json["email"] as? String        
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
    var dealStage: String!
    var ownerId: Int!
    
    init(json: [String: Any]) {
        
        let properties = json["properties"] as! [String: Any]
        
        if let owner = properties["hubspot_owner_id"] as? [String: Any],
            let ownerIdValueString = owner["value"] as? String,
            let ownerIdIntValue = Int(ownerIdValueString)
        {
            ownerId = ownerIdIntValue
        }
        
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
        
        if let dealStage = properties["dealstage"] as? [String: Any], let value = dealStage["value"] as? String
        {
            self.dealStage = value
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
