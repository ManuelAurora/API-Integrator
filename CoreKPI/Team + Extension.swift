//
//  Team + Extension.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 04.05.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension Team
{
    func getPhoto(result: @escaping (UIImage) -> ()) {
        let member = self         
        guard let link = member.photoLink, let url = URL(string: link) else {
            result(#imageLiteral(resourceName: "defaultProfile"))
            return
        }
        
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        let predicate = NSPredicate(format: "userID == \(self.userID)",
            argumentArray: nil)
        fetchRequest.predicate = predicate
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        if let res = try? context.fetch(fetchRequest),
        let team = res.first
        {
            guard let imgData = team.photo else {
                URLSession.shared.downloadTask(with: url) {
                    (location, response, error) in
                    guard let httpURLResponse = response as? HTTPURLResponse,
                        httpURLResponse.statusCode == 200,
                        error == nil,
                        let location = location
                        else {
                            result(#imageLiteral(resourceName: "defaultProfile"))
                            return
                    }
                    
                    if let imgData = NSData(contentsOf: location)
                    {
                        team.photo = imgData
                        print("Photo downloaded #")
                        do {
                            try context.save()
                        }
                        catch let error {
                            print(error.localizedDescription)
                        }
                        
                        let img = UIImage(data: imgData as Data)!
                        result(img)
                    }
                    }.resume()
                return
            }
            
            let img = UIImage(data: imgData as Data)!
            result(img)
        }
    }
}
