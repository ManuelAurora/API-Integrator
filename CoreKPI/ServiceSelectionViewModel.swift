//
//  ServiceSelectionViewModel
//  CoreKPI
//
//  Created by Manuel Aurora on 01.06.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class ServiceSelectionViewModel
{
    let model = ModelCoreKPI.modelShared
    
    func isIntegratedServicesPrepared() -> Bool {
        
        return model.integratedServices.count > 0
    }
}
