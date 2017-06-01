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

class ModelCoreKPI
{
    static var modelShared = ModelCoreKPI()
    var token: String!
    var profile: Profile!
    var alerts: [Alert] = []
    var reminders: [Reminder] = []
    var kpis: [KPI] = []
    var team: [Team] = []
    var integratedServices = [Service]() {
        didSet {
            if integratedServices.count > 0
            {
                NotificationCenter.default.post(name: .integratedServicesListLoaded,
                                                object: nil)
            }
        }
    }
    
    func signedInUpWith(token: String, profile: Profile) {
        
        self.token = token
        self.profile = profile        
    }
    
    func getNameKPI(FromID id: Int) -> String? {
        for kpi in kpis {
            if kpi.id == id {
                return (kpi.createdKPI?.KPI)!
            }
        }
        return nil
    }
    
    func getBackgroundColourOfKPI(FromID id: Int64) -> UIColor {
        for kpi in kpis {
            if kpi.id == Int(id) {
                return kpi.imageBacgroundColour
            }
        }
        return UIColor.clear
    }
    
    func getExternalServices() {
        
        let kpiLst = GetExternalServices(model: ModelCoreKPI.modelShared)
        kpiLst.getData(success: {
            (result: [Service]) in
            ModelCoreKPI.modelShared.integratedServices = result
        }) { (err) in
            print(err)
        }
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

//KPI
class KPI {    
    
    var typeOfKPI: TypeOfKPI
    var integratedKPI: ExternalKPI!
    var createdKPI: CreatedKPI?
    var id: Int
    var image: ImageForKPIList? {
        
        switch typeOfKPI
        {
        case .createdKPI:
            guard let numbers = createdKPI?.number, numbers.count >= 2 else {
                return .Increases
            }
            
            if let prelastReport = createdKPI?.prelastValue, prelastReport > 0
            {
                let currentValue  = numbers[0].number
                let previousValue = numbers[1].number
                
                return currentValue >= previousValue ? .Increases : .Decreases
            }
            
            let interval = createdKPI!.timeInterval
            var period: Calendar.Component!
            
            switch interval
            {
            case .Daily: period = .day
            case .Weekly: period = .weekOfYear
            case .Monthly: period = .month
            }
            
          return getImageFor(interval: interval, period: period)
            
        case .IntegratedKPI:
            
            let service = IntegratedServices(rawValue: integratedKPI.serviceName!) //integratedKPI?.service
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
    
    init(kpiID: Int,
         typeOfKPI: TypeOfKPI,
         integratedKPI: ExternalKPI? = nil,
         createdKPI: CreatedKPI? = nil,
         imageBacgroundColour: UIColor? = nil) {
        self.id = kpiID
        self.typeOfKPI = typeOfKPI
        self.integratedKPI = integratedKPI
        self.createdKPI = createdKPI
        self.imageBacgroundColour = imageBacgroundColour ?? UIColor.clear
    }
    
    private func getImageFor(interval: AlertTimeInterval,
                             period: Calendar.Component) -> ImageForKPIList {
        
        guard let numbers = createdKPI?.number, numbers.count >= 2 else {
            return .Increases
        }
        
        let lastReport = numbers.first!
        
        return lastReport.number >= createdKPI!.prelastValue! ? .Increases : .Decreases        
    }
}










