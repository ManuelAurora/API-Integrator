//
//  SalesForceClasses.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 11.04.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

struct Lead
{
    let name:        String!
    let id:          String!
    var isConverted: Bool! = nil
    var createdDate: Date! = nil
    let status:      String!
    let industry:    String!
    
    init(json: [String: Any]) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"
        
        name        = json["Name"]        as? String ?? ""
        id          = json["Id"]          as? String ?? ""
        isConverted = json["IsConverted"] as? Bool   ?? false
        status      = json["Status"]      as? String ?? ""
        industry    = json["Status"]      as? String ?? ""
        
        if let dateString = json["CreatedDate"] as? String,
            let date = dateFormatter.date(from: dateString)
        {
            createdDate = date
        }
    }
}

struct Revenue
{
    let amount: Float
    let date: Date
}

struct Opportunity
{    
    let name: String!
    let id: String!
    let amount: Float!
    var isWon: Bool! = nil
    var closeDate: Date! = nil
    
    init(json: [String: Any]) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        name = json["Name"] as? String ?? ""
        id   = json["Id"]   as? String ?? ""
        amount = json["Amount"] as? Float ?? 0
        isWon = json["IsWon"] as? Bool
        
        if let dateString = json["CloseDate"] as? String,
            let date = dateFormatter.date(from: dateString)
        {
            closeDate = date
        }
    }
}



