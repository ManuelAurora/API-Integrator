//
//  AddKPI.swift
//  CoreKPI
//
//  Created by Семен on 26.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class AddKPI: Request {
    
    func addKPI(kpi: KPI, success: @escaping (_ KPIid: Int) -> (), failure: @escaping failure) {
        
        var data: [String : Any] = [:]
        
        switch kpi.typeOfKPI {
        case .createdKPI:
            data = ["name" : (kpi.createdKPI?.KPI)!, "description" : kpi.createdKPI?.descriptionOfKPI ?? "nil", "department" : (kpi.createdKPI?.department.rawValue)!, "responsible_id" : (kpi.createdKPI?.executant)!, "interval" : (kpi.createdKPI?.timeInterval.rawValue)!, "delivery_day" : 1] //deadline!
        case .IntegratedKPI:
            break//data = ["name" : (kpi.integratedKPI?.serviceName)!, "description" : (kpi.integratedKPI?.service.rawValue)!, "department" : "", "responsible_id" : "", "interval" : "", "delivery_day" : ""]
        }
        
        self.getJson(category: "/kpi/addKPI", data: data,
                     success: { json in
                        if let id = self.parsingJson(json: json) {
                            success(id)
                        } else {
                            failure(self.errorMessage ?? "Wrong data from server")
                        }
        },
                     failure: { (error) in
                        failure(error)
        }
        )
    }
    
    func parsingJson(json: NSDictionary) -> Int? {
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let data = json["data"] as? NSDictionary {
                    let id = data["id"] as! Int
                    return id
                }
            } else {
                self.errorMessage = json["message"] as? String
            }
        } else {
            print("Json file is broken!")
        }
        return nil
    }
    
}
