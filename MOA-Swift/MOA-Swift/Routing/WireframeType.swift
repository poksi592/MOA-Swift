//
//  WireframeType.swift
//  MOASwift
//
//  Created by Dmitry Poznukhov on 26.10.20.
//  Copyright © 2020 1und1. All rights reserved.
//

import UIKit

/**
 This protocol have to be used to implement view controller instantiation logic
 and connect it to the business logic encapsulated in the presenter
 */
public protocol WireframeType {
    func present(using intentId: String, from intentsStorage: IntentsStorage, navigationProvider: NavigationProvider)
}
