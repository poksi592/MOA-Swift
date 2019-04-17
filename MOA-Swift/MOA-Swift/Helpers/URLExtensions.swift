//
//  URLExtensions.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 29.06.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation

public extension URL {
	
    init?(scheme: String,
                 host: String,
                 path: String? = nil,
                 parameters: [String: String]? = nil) {
		
		guard scheme.isValidSchemeName,
				host.isValidHostName else { return nil }
		
		if let path = path {
			guard path.isValidPathModule else { return nil }
		}
		
        var components = URLComponents()

        components.scheme = scheme
        components.host = host
        components.path = path ?? ""
        
        let queryItems = parameters?.map {  key, value -> URLQueryItem in
            
            return URLQueryItem.init(name: key, value: value)
        }
        components.queryItems = queryItems
        
        if let url = components.url {
            self = url
        }
        else {
            return nil
        }
    }
    
    /**
     This extension uses resource from URL in main bundle and converts it to JSON dictionary.
     
     - returns: `[String: Any]?`
    */
    func jsonFromMainBundle() -> [String: Any]? {
        
        do {
            let data = try Data(contentsOf: self)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            return json as? [String: Any]
        } catch {
            return nil
        }
    }
    
    func containsInAppScheme(for bundle: Bundle? = Bundle.main) -> Bool {
        
        guard let schemes = bundle?.urlSchemes else {
            return false
        }
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
            let scheme = components.scheme else {
                
                return false
        }
        return schemes.contains(scheme)
    }
    
    var isHttpAddress: Bool {
        
        get {
            if let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
                let scheme = components.scheme,
                let _ = components.host,
                scheme == "http" || scheme == "https" {
                
                return true
            }
            else {
                return false
            }
        }
    }
}

internal extension URLComponents {
    
    var queryItemsDictionary: [String: String]? {
        var params = [String: String]()
        return self.queryItems?.reduce([:], { (_, item) -> [String: String] in
            
                params[item.name] = item.value
                return params
        })
    }
}

internal extension String {
	
	var isValidSchemeName: Bool {
		
		get {
			guard let regex = try? NSRegularExpression(pattern: "^[A-Za-z][+-.A-Za-z0-9]*$",
													   options: NSRegularExpression.Options.caseInsensitive) else { return false }
			return self.match(with: regex)
		}
	}
	
	var isValidHostName: Bool {
		
		get {
			guard let regex = try? NSRegularExpression(pattern: "^[A-Za-z][A-Za-z0-9-]*$",
													   options: NSRegularExpression.Options.caseInsensitive) else { return false }
			return self.match(with: regex)
		}
	}
	
	var isValidPathModule: Bool {
		
		get {
			guard let regex = try? NSRegularExpression(pattern: "^[/][A-Za-z0-9-]*$",
													   options: NSRegularExpression.Options.caseInsensitive) else { return false }
			return self.match(with: regex)
		}
	}
	
	func match(with regex: NSRegularExpression) -> Bool {
		
		let range = NSRange(location: 0, length: self.utf16.count)
		return regex.firstMatch(in: self,
								options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds,
								range: range) != nil
	}
}

