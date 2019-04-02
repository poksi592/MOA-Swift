//
//  Dashboard.swift
//  DynamicDataDrivenApp
//
//  Created by Mladen Despotovic on 03.12.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation

class Dashboard: ApplicationServiceType {

    internal var serviceParameters: [String: Any] = [:]
    internal var service: [String: Any] = [:]
    var appRouter: ApplicationRouterType = ApplicationRouter()
    internal var scheme = "yourbank"
    
    var bundle = Bundle.main
    
	required init(jsonFilename: String? = nil, bundle: Bundle = Bundle.main) {
        
        if let serviceDictionary = bundle.loadJson(filename: "Dashboard2") {
            self.service = serviceDictionary
        }
    }
}
