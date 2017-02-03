//
//  ModelCoreKPI.swift
//  CoreKPI
//
//  Created by Семен on 20.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit
import CoreData

enum TypeOfAccount: String {
    case Admin
    case Manager
}

class ModelCoreKPI: NSObject, NSCoding {
    
    let token: String
    var profile: Profile?
    
    var alerts: [Alert] = []
    var kpis: [KPI] = []
    var team: [Team] = []
    
    required init(token: String, userID: Int) {
        self.token = token
        self.profile = Profile(userID: userID)
    }
    
    required init(coder decoder: NSCoder) {
        self.token = decoder.decodeObject(forKey: "token") as? String ?? ""
        let id = decoder.decodeObject(forKey: "userID") as? Int ?? 0
        self.profile = Profile(userID: id)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(token, forKey: "token")
        coder.encode(self.profile?.userId, forKey: "userID")
    }
    
    init(token: String, profile: Profile?) {
        self.token = token
        self.profile = profile
    }
    init(model: ModelCoreKPI) {
        self.token = model.token
        self.profile = model.profile
        self.alerts = model.alerts
        self.kpis = model.kpis
        self.team = model.team
    }
    
    func getNameKPI(FromID id: Int) -> String? {
        for kpi in kpis {
            if kpi.id == id {
                return (kpi.createdKPI?.KPI)!
            }
        }
        return nil
    }
    
}

//Profile
class Profile {
    var userId: Int
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

    init(userID: Int) {
        self.userId = userID
        self.userName = ""
        self.firstName = ""
        self.lastName = ""
        self.position = nil
        self.photo = nil
        self.phone = nil
        self.nickname = nil
        self.typeOfAccount = .Manager
        
    }
    
}

//Alerts
//struct Alert {
//    var image: String
//    var dataSource: DataSource
//    var timeInterval: TimeInterval?
//    var deliveryDay: String?
//    var timeZone: String?
//    var condition: Condition?
//    var threshold: String?
//    var deliveryTime: String
//    var typeOfNotification: [TypeOfNotification]
//}

//KPI
class KPI {
    var typeOfKPI: TypeOfKPI
    var integratedKPI: IntegratedKPI?
    var createdKPI: CreatedKPI?
    var id: Int
    var image: ImageForKPIList? {
        
        switch typeOfKPI {
        case .createdKPI:
            let numbers = createdKPI?.number
            if (numbers?.count)! > 1 {
                switch (createdKPI?.timeInterval)! {
                case .Daily: break
                    //let date = Date()
                    //date.compare(Date(timeIntervalSinceNow: 20))
                case .Weekly: break
                case .Monthly: break
                }
                if (numbers?[(numbers?.count)! - 1])! < (numbers?[(numbers?.count)! - 2])! {
                    return ImageForKPIList.Decreases
                }
                if (numbers?[(numbers?.count)! - 1])! > (numbers?[(numbers?.count)! - 2])! {
                    return ImageForKPIList.Increases
                }
                
            }
            return nil
        case .IntegratedKPI:
            let service = integratedKPI?.service
            switch service! {
            case .none:
                return nil
            case .SalesForce:
                return ImageForKPIList.SaleForce
            case .Quickbooks:
                return ImageForKPIList.QuickBooks
            case .GoogleAnalytics:
                return ImageForKPIList.GoogleAnalytics
            case .HubSpotCRM:
                return ImageForKPIList.HubSpotCRM
            case .PayPal:
                return ImageForKPIList.PayPal
            case .HubSpotMarketing:
                return ImageForKPIList.HubSpotMarketing
            }
        }
    }
    var imageBacgroundColour: UIColor
    var KPIViewOne: TypeOfKPIView = TypeOfKPIView.Numbers
    var KPIChartOne: TypeOfChart? = TypeOfChart.PieChart
    var KPIViewTwo: TypeOfKPIView? = TypeOfKPIView.Graph
    var KPIChartTwo: TypeOfChart? = TypeOfChart.PieChart
    
    init(kpiID: Int ,typeOfKPI: TypeOfKPI, integratedKPI: IntegratedKPI?, createdKPI: CreatedKPI?, imageBacgroundColour: UIColor?) {
        self.id = kpiID
        self.typeOfKPI = typeOfKPI
        self.integratedKPI = integratedKPI
        self.createdKPI = createdKPI
        self.imageBacgroundColour = imageBacgroundColour ?? UIColor.clear
    }
    
}
