//
//  GetMemberList.swift
//  CoreKPI
//
//  Created by Семен on 24.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit
import PhoneNumberKit
import CoreData

class GetMemberList: Request
{
    
    func getMemberList(success: @escaping (_ teamArray: [Team]) -> (), failure: @escaping failure) {
        
        let data: [String : Any] = [ : ]
        
        self.getJson(category: "/team/getTeamList", data: data,
                     success: { json in
                        if let team = self.parsingJson(json: json) {
                            success(team)
                        } else {
                            failure(self.errorMessage ?? "Wrong data from server")
                        }
        },
                     failure: { (error) in
                        failure(error)
                        
        }
        )
    }
    
    private func fill(team: Team, with userData: jsonDict) {
        
        let phoneNumberKit = PhoneNumberKit()
        let photoServer = Request.avatarsLink
        let position = userData["position"] as? String
        let teamId = userData["user_id"] as! Int64
        let mode = userData["mode"] as! Int
        let isAdmin = mode == 0 ? false : true
        let nickname = userData["nickname"] as? String
        let lastName = userData["last_name"] as? String
        let firstName = userData["first_name"] as? String
        let username = userData["username"] as? String
        let phone = userData["phone"] as? String
        var photoLink = ""
        if let photo = userData["photo"] as? String
        {
            photoLink = photoServer + photo
        }
        
        team.userID = teamId
        team.position = position
        team.isAdmin = isAdmin
        team.nickname = nickname
        team.lastName = lastName
        team.firstName = firstName
        team.username = username
        team.photoLink = photoLink
        
        if let number = phone,
            let phoneNumber = try? phoneNumberKit.parse("+\(number)")
        {
            team.phoneNumber = phoneNumberKit.format(phoneNumber,
                                                     toType: .international)
        }
    }
    
    func parsingJson(json: NSDictionary) -> [Team]? {
        
        let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
        
        
        guard let successKey = json["success"] as? Int,
            successKey == 1 else {
                print("Json file is broken!")
                return nil
        }
        
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        
        if let teamMembers = json["data"] as? [jsonDict]
        {
            if let teamArray = try? context.fetch(fetchRequest), teamArray.count > 0
            {
                teamArray.forEach { team in
                    let member = teamMembers.filter {
                        let id = $0["user_id"] as! Int64
                        return team.userID == id
                        }.first
                    
                    if let userData = member
                    {
                        fill(team: team, with: userData)
                    }
                    else
                    {
                        context.delete(team)
                    }
                }
            }
            else
            {
                teamMembers.forEach { userData in
                    
                    let entDescr = NSEntityDescription.entity(forEntityName: "Team",
                                                              in: context)!
                    
                    let team = Team(entity: entDescr, insertInto: context)
                    
                    fill(team: team, with: userData)
                }
            }
            
            do {
                try context.save()
                return try context.fetch(fetchRequest)
            }
            catch let error {
                print(error.localizedDescription)
                return nil
            }
        }
        return nil 
    }
    
}

