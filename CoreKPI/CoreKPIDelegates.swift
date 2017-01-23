//
//  CoreKPIDelegates.swift
//  CoreKPI
//
//  Created by Семен on 22.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit

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
    func updateProfile(profile: Team)
}

protocol updateSettingsDelegate {
    func updateSettingsArray(array: [(SettingName: String, value: Bool)])
    func updateStringValue(string: String?)
    func updateDoubleValue(number: Double?)
}

protocol updateNicknameDelegate {
    func updateNickname(nickname: String)
}

protocol updateAlertListDelegate {
    func updateAlertList(alertArray: [Alert])
    func addAlert(alert: Alert)
}

protocol updateKPIListDelegate {
    func updateKPIList(kpiArray: [KPI])
    func addNewKPI(kpi: KPI)
}

protocol KPIListButtonCellDelegate {
    func editButtonDidTaped(sender: UIButton)
    func reportButtonDidTaped(sender: UIButton)
    func memberNameDidTaped(sender: UIButton)
}

protocol AlertButtonCellDelegate {
    func deleteButtonDidTaped(sender: UIButton)
}
