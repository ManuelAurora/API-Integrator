//
//  ModelCoreKPI.swift
//  CoreKPI
//
//  Created by Семен on 20.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import Foundation

class ModelCoreKPI {
    let userId: Int
    let token: String
    
    let profile: Profile?
    
    init(userId: Int, token: String, profile: Profile?) {
        self.userId = userId
        self.token = token
        self.profile = profile
    }
    
}


class Profile {
    var userName: String
    var firstName: String
    var middleName: String
    var lastName: String
    var position: String?
    var photo: Data?
    
    init(userName: String, firstName: String, middleName: String, lastName: String, position: String?, photo: Data?) {
        self.userName = userName
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
        self.position = position
        self.photo = photo
    }
    
    init(profile: Profile) {
        self.userName = profile.userName
        self.firstName = profile.firstName
        self.middleName = profile.middleName
        self.lastName = profile.lastName
        self.position = profile.position
        self.photo = profile.photo
    }
    
}
