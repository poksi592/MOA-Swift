//
//  ResponseError.swift
//  MOASwift
//
//  Created by Dmitry Poznukhov on 09.10.20.
//  Copyright © 2020 1und1. All rights reserved.
//

import Foundation

/**
 enum defines(but not limit) set of predefined most common errors modules can return
*/
public enum ResponseError: Error {
    case serializationFailed
    case taskCancelled
    case badRequest400(error: Error?)
    case unauthorized401(error: Error?)
    case forbidden403(error: Error?)
    case notFound404(error: Error?)
    case other400(error: Error?)
    case serverError500(error: Error?)
    case other

    var errorCode: Int? {
        switch self {
        case .badRequest400:
            return 400
        case .unauthorized401:
            return 401
        case .forbidden403:
            return 403
        case .notFound404:
            return 404
        case .other400:
            return 405
        case .serverError500:
            return 500
        case .serializationFailed, .taskCancelled, .other:
            return nil
        }
    }

    public init?(error: Error?, response: HTTPURLResponse?, code: Int? = nil) {
        let responseCode: Int
        if let response = response {
            responseCode = response.statusCode
        } else if let code = code {
            responseCode = code
        } else {
            responseCode = 0
            self = .other
        }

        switch responseCode {
        case 200..<300:
            return nil
        case 400:
            self = .badRequest400(error: error)
        case 401:
            self = .unauthorized401(error: error)
        case 403:
            self = .forbidden403(error: error)
        case 404:
            self = .notFound404(error: error)
        case 405..<500:
            self = .other400(error: error)
        case 500..<600:
            self = .serverError500(error: error)
        default:
            self = .other
        }
    }
}
