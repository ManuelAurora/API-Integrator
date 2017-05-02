//
//  Messages.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 28.04.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

public enum MessageType: String
{
    case support = "Support"
    case request = "Request"
}

struct QuestionAnswer
{
    var question: String = ""
    var answer: String = ""
    var id: Int
    var userId: Int
}

class MessagesRequestManager: Request {
    
    func send(message: String, type: MessageType, success: @escaping () -> (), failure: @escaping failure) {
        
        let data = [
            "message": message,
            "type": type.rawValue
            ]
      
        self.getJson(category: "/chat/sendMessage", data: data,
                     success: { json in
                        guard let suc = json["success"] as? Int, suc == 1 else {
                            if let errorMessage = json["message"] as? String
                            {
                                failure(errorMessage)
                            }
                            return
                        }
                        _ = self.parsingJson(json: json)
                        success()
        },
                     failure: { (error) in
                        failure(error)
        })
    }
    
    func getMessagesOf(type: MessageType, success: @escaping ([QuestionAnswer]) -> (), failure: @escaping failure) {

        let data = [
            "type": type.rawValue
        ]
        
        self.getJson(category: "/chat/getMessages", data: data,
                     success: { json in
                        guard let suc = json["success"] as? Int, suc == 1 else {
                            if let errorMessage = json["message"] as? String
                            {
                                failure(errorMessage)
                            }
                            return
                        }
                        
                        let result = self.parsingJson(json: json)
                        success(result)
        },
                     failure: { (error) in
                        failure(error)
        })
        
    }
    
    func parsingJson(json: NSDictionary) -> [QuestionAnswer] {
        
        var result = [QuestionAnswer]()
        
        if let successKey = json["success"] as? Int,
            successKey == 1,
            let messages = json["data"] as? [[jsonDict]]
        {
            var conversation = QuestionAnswer(question: "",
                                              answer: "",
                                              id: 0,
                                              userId: 0)
            
            messages.forEach { messagesChain in
                messagesChain.forEach {
                    let direction = $0["direction"] as! String
                    let text      = $0["message"] as! String
                    let id        = $0["id"] as! Int64
                    let userId    = $0["user_id"] as! Int64
                    if direction == "To"
                    {
                        conversation.question = text
                    }
                    else { conversation.answer = " Reply: " + text }
                    
                    conversation.id = Int(id)
                    conversation.userId = Int(userId)
                }
                result.append(conversation)
                conversation.question = ""
                conversation.answer   = ""
            }
        }
        return result
    }
}
