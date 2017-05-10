//
//  DeleteIntegratedKPI.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 10.05.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

//removeIntegratedKPI(int_kpi_id)

import Foundation

class DeleteIntegratedKPI: Request {
    
    func deleteKPI(kpiID: Int, success: @escaping () -> (), failure: @escaping failure) {
        
        let data: [String : Any] = ["id" : kpiID]
        
        self.getJson(category: "/kpi/removeIntegratedKPI", data: data,
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
