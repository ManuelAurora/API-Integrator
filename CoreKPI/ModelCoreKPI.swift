//
//  ModelCoreKPI.swift
//  CoreKPI
//
//  Created by Семен on 20.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import Foundation

enum TypeOfAccount: String {
    case Admin
    case Manager
}

class ModelCoreKPI {
    let userId: Int
    let token: String
    
    let profile: Profile?
    
    init(userId: Int, token: String, profile: Profile?) {
        self.userId = userId
        self.token = token
        self.profile = profile
    }
    init(model: ModelCoreKPI) {
        self.userId = model.userId
        self.token = model.token
        self.profile = model.profile
    }
    
}


class Profile {
    var userName: String
    var firstName: String
    var lastName: String
    var position: String?
    var photo: String?
    var phone: String?
    var typeOfAccount: TypeOfAccount
    
    init(userName: String, firstName: String, lastName: String, position: String?, photo: String?, phone: String?, typeOfAccount: TypeOfAccount) {
        self.userName = userName
        self.firstName = firstName
        self.lastName = lastName
        self.position = position
        self.photo = photo
        self.phone = phone
        self.typeOfAccount = typeOfAccount
    }
    
    init(profile: Profile) {
        self.userName = profile.userName
        self.firstName = profile.firstName
        self.lastName = profile.lastName
        self.position = profile.position
        self.photo = profile.photo
        self.phone = profile.phone
        self.typeOfAccount = profile.typeOfAccount
    }
    
}
