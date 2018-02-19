//
//  LightsRouter.swift
//  HueExpression
//
//  Created by Kyle Haptonstall on 2/17/18.
//  Copyright © 2018 Kyle Haptonstall. All rights reserved.
//

import Foundation

enum LightsRouter: Router {
    
    private enum Constant {
        static let lightsPath = "lights"
        static let lightStatePath = "state"
        static let apiKeyIsOn = "on"
        static let apiKeyHue = "hue"
    }
    
    case getLights
    case updateLightState(id: String, isOn: Bool?, hue: UInt16?)
    
    var method: HTTPMethod {
        switch self {
        case .getLights:
            return .get
        case .updateLightState:
            return .put
        }
    }
    
    var path: String {
        switch self {
        case .getLights:
            return Constant.lightsPath
        case .updateLightState(let id, _, _):
            return "\(Constant.lightsPath)/\(id)/\(Constant.lightStatePath)"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .getLights:
            return nil
        case .updateLightState(_, let isOn, let hue):
            var parameters: [String: Any] = [:]
            
            if let isOn = isOn {
                parameters[Constant.apiKeyIsOn] = isOn
            }
            
            if let hue = hue {
                parameters[Constant.apiKeyHue] = hue
            }
            
            if parameters.keys.count > 0 {
                return parameters
            } else {
                return nil
            }
        }
    }
    
}
