//
//  SalesforceRequestManager.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 10.04.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class SalesforceRequestManager
{
    static let shared = SalesforceRequestManager()
    
    struct Methods
    {
        static let tooling             = "/services/data/v39.0/tooling"
        static let eclair              = "/services/data/v39.0/eclair"
        static let prechatForms        = "/services/data/v39.0/prechatForms"
        static let chatter             = "/services/data/v39.0/chatter"
        static let tabs                = "/services/data/v39.0/tabs"
        static let appMenu             = "/services/data/v39.0/appMenu"
        static let quickActions        = "/services/data/v39.0/quickActions"
        static let queryAll            = "/services/data/v39.0/queryAll"
        static let commerce            = "/services/data/v39.0/commerce"
        static let wave                = "/services/data/v39.0/wave"
        static let analytics           = "/services/data/v39.0/analytics"
        static let search              = "/services/data/v39.0/search"
        static let composite           = "/services/data/v39.0/composite"
        static let parameterizedSearch = "/services/data/v39.0/parameterizedSearch"
        static let theme               = "/services/data/v39.0/theme"
        static let nouns               = "/services/data/v39.0/nouns"
        static let event               = "/services/data/v39.0/event"
        static let serviceTemplates    = "/services/data/v39.0/serviceTemplates"
        static let recent              = "/services/data/v39.0/recent"
        static let connect             = "/services/data/v39.0/connect"
        static let licensing           = "/services/data/v39.0/licensing"
        static let limits              = "/services/data/v39.0/limits"
        static let process             = "/services/data/v39.0/process"
        static let asyncQueries        = "/services/data/v39.0/async-queries"
        static let query               = "/services/data/v39.0/query"
        static let match               = "/services/data/v39.0/match"
        static let emailConnect        = "/services/data/v39.0/emailConnect"
        static let compactLayouts      = "/services/data/v39.0/compactLayouts"
        static let knowledgeManagement = "/services/data/v39.0/knowledgeManagement"
        static let sobjects            = "/services/data/v39.0/sobjects"
        static let actions             = "/services/data/v39.0/actions"
        static let support             = "/services/data/v39.0/support"
    }
    
    var instanceURL: String!
    var idURL: String!
    
}
