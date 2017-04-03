//
//  HubspotKPI.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 03.04.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension HubspotKPI
{
    convenience init() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let description = NSEntityDescription.entity(forEntityName: "HubspotKPI", in: managedContext)!
        self.init(entity: description, insertInto: managedContext)
    }
}
