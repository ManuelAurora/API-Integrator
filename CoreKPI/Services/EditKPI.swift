//
//  EditKPI.swift
//  CoreKPI
//
//  Created by Семен on 27.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class EditKPI: Request {
    
    func editKPI(kpi: KPI, success: @escaping () -> (), failure: @escaping failure) {
        
        let data: [String : Any] = ["kpi_id" : kpi.id ,"name" : (kpi.createdKPI?.KPI)!, "description" : kpi.createdKPI?.descriptionOfKPI ?? "nil", "department" : (kpi.createdKPI?.department.rawValue)!, "responsible_id" : (kpi.createdKPI?.executant)!, "interval" : (kpi.createdKPI?.timeInterval.rawValue)!, "delivery_day" : 1] //deadline!
        
        self.getJson(category: "/kpi/updateKPI", data: data,
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
