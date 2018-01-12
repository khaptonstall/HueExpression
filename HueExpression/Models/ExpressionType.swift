//
//  ExpressionType.swift
//  HueExpression
//
//  Created by Kyle Haptonstall on 1/11/18.
//  Copyright © 2018 Kyle Haptonstall. All rights reserved.
//

import Foundation

enum ExpressionType {
    
    // MARK: Cases
    
    case happy
    case mad
    
    // MARK: - Variables
    // MARK: Public
    
    var hueValue: UInt16 {
        switch self {
        case .happy:
            return 25500 //Green
        case .mad:
            return 65535 //Red
        }
    }
    
}
