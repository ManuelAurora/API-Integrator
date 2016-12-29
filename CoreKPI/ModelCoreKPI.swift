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
    let token: String
    
    let profile: Profile?
    
    init(token: String, profile: Profile?) {
        self.token = token
        self.profile = profile
    }
    init(model: ModelCoreKPI) {
        self.token = model.token
        self.profile = model.profile
    }
    
}


class Profile {
    let userId: Int
    var userName: String
    var firstName: String
    var lastName: String
    var position: String?
    var photo: String?
    var phone: String?
    var nickname: String?
    var typeOfAccount: TypeOfAccount
    
    init(userId: Int, userName: String, firstName: String, lastName: String, position: String?, photo: String?, phone: String?, nickname: String?, typeOfAccount: TypeOfAccount) {
        self.userId = userId
        self.userName = userName
        self.firstName = firstName
        self.lastName = lastName
        self.position = position
        self.photo = photo
        self.phone = phone
        self.nickname = nickname
        self.typeOfAccount = typeOfAccount
    }
    
    init(profile: Profile) {
        self.userId = profile.userId
        self.userName = profile.userName
        self.firstName = profile.firstName
        self.lastName = profile.lastName
        self.position = profile.position
        self.photo = profile.photo
        self.phone = profile.phone
        self.nickname = profile.nickname
        self.typeOfAccount = profile.typeOfAccount
    }
    
}
