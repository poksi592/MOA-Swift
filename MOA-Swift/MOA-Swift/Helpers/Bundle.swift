//
//  Bundle.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 29.06.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//


import Foundation

extension Bundle {
    
    var urlSchemes: [String]? {
        
        get {
            guard let urlTypes = self.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: AnyObject]] else {
                return nil
            }
            let urlSchemes = urlTypes.compactMap { (item) -> [String]? in
                
                guard let schemes = item["CFBundleURLSchemes"] as? [String] else {
                    
                    return nil
                }
                return schemes
            }
            return urlSchemes.flatMap { $0 }
        }
    }
    
    func loadJson(filename: String) -> [String: Any]? {
        
        guard let filepath = self.path(forResource: filename, ofType: "json") else { return nil }
        let url = URL(fileURLWithPath: filepath)
        guard let data = try? Data(contentsOf: url),
            let deserialised = try? JSONSerialization.jsonObject(with: data,
                                                                 options: JSONSerialization.ReadingOptions.allowFragments),
            let serviceDictionary = deserialised as? [String: Any] else { return nil }

        return serviceDictionary
    }
}
