//
//  ExternalRequestService.swift
//  CoreKPI
//
//  Created by Семен on 07.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import Alamofire

class ExternalRequest {
    
    var errorMessage: String?
    
    var url = ""
    
    init(url: String) {
    self.url = url
    }
    
    typealias success = (_ json: NSDictionary) -> ()
    typealias failure = (_ error: String) -> ()
    
    //MARK: - Send request
    func getJson(header: [String : String]?, params: [String: Any]?, method: HTTPMethod, success: @escaping success, failure: @escaping failure) {
        
        request(url, method: method, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { response in
            if let data = response.data {
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                    if let jsonDictionary = json {
                        success(jsonDictionary)
                    } else {
                        failure("Load failed")
                    }
                    
                } catch {
                    guard response.result.isSuccess else {
                        let error = response.result.error
                        if let error = error, (error as NSError).code != NSURLErrorCancelled {
                            let requestError = error.localizedDescription
                            failure(requestError)
                        }
                        return
                    }
                }
            }
        }
    }
    
}
