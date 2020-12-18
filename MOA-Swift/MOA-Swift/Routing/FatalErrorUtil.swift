//
//  FatalErrorUtil.swift
//  MOASwift
//
//  Created by Dmitry Poznukhov on 12.11.20.
//  Copyright © 2020 1und1. All rights reserved.
//

import Foundation

protocol FatalErrorUtil {
    func fatalError()
}

struct DefaultFatalErrorUtil: FatalErrorUtil {
    func fatalError() {
        Swift.fatalError()
    }
}
