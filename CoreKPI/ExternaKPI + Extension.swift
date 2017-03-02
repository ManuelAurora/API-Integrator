//
//  ExternaKPI + Extension.swift
//  CoreKPI
//
//  Created by Мануэль on 02.03.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension ExternalKPI
{
    convenience init() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let description = NSEntityDescription.entity(forEntityName: "ExternalKPI", in: managedContext)!
        self.init(entity: description, insertInto: managedContext)
    }
}
