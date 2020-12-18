//
//  URLExtensions.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 29.06.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation

public extension URL {
    init?(scheme: String, host: String, path: String? = nil, parameters: [String: String]? = nil) {
        guard scheme.isValidSchemeName else { return nil }
        guard host.isValidHostName else { return nil }

        if let path = path {
            guard path.isValidPathModule else { return nil }
        }

        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path ?? ""
        let queryItems = parameters?.map { URLQueryItem.init(name: $0, value: $1) }
        components.queryItems = queryItems

        if let url = components.url {
            self = url
        } else {
            return nil
        }
    }
}

extension URLComponents {
    var queryItemsDictionary: [String: String] {
        queryItems?.reduce([String: String]()) {
            $0.merging([$1.name: $1.value ?? ""]) { current, _ in current }
        } ?? [:]
    }
}

extension String {
    var isValidSchemeName: Bool {
        let pattern = "^[A-Za-z][+-.A-Za-z0-9]*$"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return false }
        return self.match(with: regex)
    }

    var isValidHostName: Bool {
        let pattern = "^[A-Za-z][A-Za-z0-9-]*$"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return false }
        return self.match(with: regex)
    }

    var isValidPathModule: Bool {
        let pattern = "^[/][A-Za-z0-9-]*$"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return false }
        return self.match(with: regex)
    }

    private func match(with regex: NSRegularExpression) -> Bool {
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.firstMatch(in: self, options: .withoutAnchoringBounds, range: range) != nil
    }
}
