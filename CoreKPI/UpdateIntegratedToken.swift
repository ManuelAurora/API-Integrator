//
//  RefreshIntegratedKPIToken.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 12.05.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

//updateIntegratedToken(int_kpi_id, token, refresh_token, [ttl])

class UpdateIntegratedToken: Request {
    
    func update(token: String,
                refreshToken: String,
                kpiId: Int,
                ttl: Int,
                success: @escaping () -> (),
                failure: @escaping failure) {
        
        let data: jsonDict = [
            "int_kpi_id":    kpiId,
            "token":         token,
            "refresh_token": refreshToken,
            "ttl":           ttl
        ]
        
        self.getJson(category: "/kpi/updateIntegratedToken", data: data,
                     success: { json in
                        guard let suc = json["success"] as? Int, suc == 1 else {
                            if let errorMessage = json["message"] as? String
                            {
                                failure(errorMessage)
                            }
                            return
                        }
                        success(self.parsingJson(json: json))
        },
                     failure: { (error) in
                        failure(error)
        })
    }
    
    private func parsingJson(json: NSDictionary) {
        
        if let successKey = json["success"] as? Int,
            successKey == 1,
            let data = json["data"] as? [jsonDict]
        {
            //TODO
        }
        
    }
}



