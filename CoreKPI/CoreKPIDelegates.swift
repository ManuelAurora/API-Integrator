//
//  CoreKPIDelegates.swift
//  CoreKPI
//
//  Created by Семен on 22.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import Foundation

protocol registerDelegate {
    func updateLoginAndPassword(email: String, password: String)
}

protocol updateModelDelegate {
    func updateModel(model: ModelCoreKPI)
}

protocol updateTypeOfAccountDelegate {
    func updateTypeOfAccount(typeOfAccount: TypeOfAccount)
}

protocol updateProfileDelegate {
    func updateProfile(profile: Profile)
}

protocol updateSettingsArrayDelegate {
    func updateSettingsArray(array: [(String, Bool)])
}

protocol updateNicknameDelegate {
    func updateNickname(nickname: String)
}
