//
//  GetExternalServices.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 05.05.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
//getExternalServices

struct Service
{
    let name: String
    let id: Int
}

class GetExternalServices: Request
{
    func getData(success: @escaping (_ services: [Service]) -> (), failure: @escaping failure) {
        
        let data: [String : Any] = [:]
        
        self.getJson(category: "/service/getExternalServices", data: data,
            success: { json in
                if let services = self.parsingJson(json: json) {
                    success(services)
                } else {
                    failure(self.errorMessage ?? "Wrong data from server")
                }
        },
            failure: { (error) in
                failure(error)
        })
    }
    
    func parsingJson(json: NSDictionary) -> [Service]? {
        
        if let successKey = json["success"] as? Int,
            successKey == 1,
            let data = json["data"] as? jsonDict,
            let services = data["list"] as? [jsonDict] {
            
            return services.map {
                let service = Service(name: $0["name"] as! String,
                                      id: $0["id"] as! Int)
                return service
            }
        }
        return nil
    }
}
