//
//  ServiceSelectionViewModel
//  CoreKPI
//
//  Created by Manuel Aurora on 01.06.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit

class ServiceSelectionViewModel
{
    let model = ModelCoreKPI.modelShared
    let datasource = SelectServiceDatasource()
    
    func sectionTypeFor(indexPath: IndexPath) -> SelectServiceDatasource.SectionType {
        return datasource.sections[indexPath.section]
    }
    
    func getNumberOfCellsIn(section: Int) -> Int {
        
        let sectionType = datasource.sections[section]
        
        switch sectionType
        {
        case .custom: return 1
        case .integrated: return datasource.kpiSources.count
        }
    }
    
    func getNumberOfSections() -> Int {
        
        return datasource.sections.count
    }
    
    func isIntegratedServicesPrepared() -> Bool {
        
        return model.integratedServices.count > 0
    }    
}
