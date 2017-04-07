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

protocol updateSettingsDelegate: class {
    func updateSettingsArray(array: [(SettingName: String, value: Bool)])
    func updateStringValue(string: String?)
    func updateDoubleValue(number: Double?)
}

protocol updateNicknameDelegate {
    func updateNickname(nickname: String)
}

protocol updateKPIListDelegate {
    func updateKPIList(kpiArray: [KPI])
    func addNewKPI(kpi: KPI)
}

protocol KPIListButtonCellDelegate {
    func userTapped(button: UIButton, edit: Bool)
    func memberNameDidTaped(sender: UIButton)
    func deleteDidTaped(sender: UIButton)
}

protocol AlertButtonCellDelegate {
    func deleteButtonDidTaped(sender: UIButton)
}

protocol UpdateTimeDelegate {
    func updateTime(newTime time: Date)
}

//protocol UpdateExternalTokensDelegate {
//    func updateTokens(oauthToken: String, oauthRefreshToken: String, oauthTokenExpiresAt: Date?, viewID: String?)
//}
//
//protocol UpdatePayPalAPICredentialsDelegate {
//    func updatePayPalCredentials(payPalObject: PayPalKPI)
//}

protocol UpdateExternalKPICredentialsDelegate {
    func updateCredentials(googleAnalyticsObject: GoogleKPI?, payPalObject: PayPalKPI?, salesForceObject: SalesForceKPI?)
}
