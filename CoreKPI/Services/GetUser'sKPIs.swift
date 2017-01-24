//
//  GetUser'sKPIs.swift
//  CoreKPI
//
//  Created by Семен on 24.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class GetUserKPIs: GetKPIs {
    
    func getUserKPIs(userID: Int, success: @escaping (_ arrayOfKPI: [KPI]) -> (), failure: @escaping failure)
    {
        let data: [String : Any] = ["user_id": userID]
        
        self.getJson(category: "/kpi/getUserKPIs", data: data,
                        success: { json in
                            if let arrayOfKPI = self.parsingJson(json: json) {
                                success(arrayOfKPI)
                            } else {
                                failure(self.errorMessage ?? "Wrong data from server")
                            }
        },
                        failure: { (error) in
                            failure(error)
        }
        )
    }
}

    
