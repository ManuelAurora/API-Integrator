//
//  GetIntegratedKPIs.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 05.05.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit

class GetIntegratedKPIs: Request {
    
    func getKPIsFromServer(success: @escaping (_ arrayOfKPI: [KPI]) -> (), failure: @escaping failure) {
        
        let data: [String : Any] = [:]
        
        self.getJson(category: "/kpi/getIntegratedKPIList", data: data,
                     success: { json in
                        if let arrayOfKPI = self.parsingJson(json: json) {
                            success(arrayOfKPI)
                        } else {
                            failure(self.errorMessage ?? "Wrong data from server")
                        }
        },
                     failure: { (error) in
                        failure(error)
        })
    }
    
    func parsingJson(json: NSDictionary) -> [KPI]? {
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? [jsonDict] {
                    var arrayOfKPI: [KPI] = []
                    
                }
            }
        }
        return nil
    }
}
