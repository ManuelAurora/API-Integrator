//
//  updateKPI.swift
//  CoreKPI
//
//  Created by Семен on 26.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class UpdateKPI: Request {
    
    func updateKPI(kpi: KPI, success: @escaping () -> (), failure: @escaping failure) {
        
        var data: [String : Any] = [:]
        
        switch kpi.typeOfKPI {
        case .createdKPI:
            data = ["id" : kpi.id ,"name" : (kpi.createdKPI?.KPI)!, "description" : (kpi.createdKPI?.descriptionOfKPI)!, "department" : (kpi.createdKPI?.department.rawValue)!, "responsible_id" : (kpi.createdKPI?.executant)!, "interval" : (kpi.createdKPI?.timeInterval.rawValue)!, "delivery_day" : (kpi.createdKPI?.deadline)!]
        case .IntegratedKPI:
            data = ["id" : kpi.id, "name" : (kpi.integratedKPI?.service.rawValue)!, "description" : (kpi.integratedKPI?.service.rawValue)!, "department" : "", "responsible_id" : "", "interval" : "", "delivery_day" : ""]
        }
        
        self.getJson(category: "/kpi/addKPI", data: data,
                     success: { json in
                        if self.parsingJson(json: json) {
                            success()
                        } else {
                            failure(self.errorMessage ?? "Wrong data from server")
                        }
        },
                     failure: { (error) in
                        failure(error)
        }
        )
    }
    
    func parsingJson(json: NSDictionary) -> Bool {
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                return true
            } else {
                self.errorMessage = json["message"] as? String
            }
        } else {
            print("Json file is broken!")
        }
        return false
    }
    
}
