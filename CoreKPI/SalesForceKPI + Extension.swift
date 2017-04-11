//
//  SalesForceKPI + Extension.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 11.04.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension SalesForceKPI
{
    convenience init() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context     = appDelegate.persistentContainer.viewContext
        
        let description = NSEntityDescription.entity(forEntityName: "SalesForceKPI", in: context)!
        self.init(entity: description, insertInto: context)
    }
}
