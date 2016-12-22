//
//  CoreKPIDelegates.swift
//  CoreKPI
//
//  Created by Семен on 22.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import Foundation

protocol registerDelegate {
    func updateLoginAndPassword(email: String, password: String)
}

protocol updateModelDelegate {
    func updateModel(model: ModelCoreKPI)
}
