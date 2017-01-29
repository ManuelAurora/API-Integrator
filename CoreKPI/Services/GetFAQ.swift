//
//  GetFAQ.swift
//  CoreKPI
//
//  Created by Семен on 27.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class GetFAQ: Request {
    
    func getFAQ(success: @escaping ([FAQSection : [(description: String, answer: String)]]) -> (), failure: @escaping failure) {
        
        let data: [String : Any] = [:]
        
        self.getJson(category: "/support/getFAQ", data: data,
                     success: { json in
                        if let reports = self.parsingJson(json: json) {
                            success(reports)
                        } else {
                            failure(self.errorMessage ?? "Wrong data from server")
                        }
        },
                     failure: { (error) in
                        failure(error)
        }
        )
    }
    
    func parsingJson(json: NSDictionary) -> [FAQSection : [(description: String, answer: String)]]?  {
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSArray, dataKey.count > 0 {
                    
                    var faqDictionary: [FAQSection : [(description: String, answer: String)]] = [:]
                    
                    for i in 0..<dataKey.count {
                        if let section = dataKey[i] as? NSDictionary {
                            if let sectionName = section["title"] as? String, let sectionFAQ = FAQSection(rawValue: sectionName) {
                                var faqArray: [(description: String, answer: String)] = []
                                if let items = section["items"] as? NSArray, items.count > 0 {
                                    for item in 0..<items.count {
                                        let question = items[item] as? NSDictionary
                                        let faqDescription = question?["title"] as! String
                                        let faqAnswer = question?["text"] as! String
                                        faqArray.append((faqDescription, faqAnswer))
                                    }
                                    faqDictionary[sectionFAQ] = faqArray
                                } else {
                                    print("Answers for \(sectionName) is empty")
                                }
                            }
                        }
                    }
                    
                    return faqDictionary
                } else {
                    print("FAQ list is empty")
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
