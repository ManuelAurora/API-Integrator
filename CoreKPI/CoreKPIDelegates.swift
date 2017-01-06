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
    func updateSettingsArray(array: [(SettingName: String, value: Bool)])
    func updateStringValue(string: String?)
}

protocol updateNicknameDelegate {
    func updateNickname(nickname: String)
}

protocol updateAlertListDelegate {
    func addAlert(alert: Alert)
}
