//
//  Light.swift
//  HueExpression
//
//  Created by Kyle Haptonstall on 2/18/18.
//  Copyright © 2018 Kyle Haptonstall. All rights reserved.
//

import Foundation

class Light: Decodable {
    
    // MARK: - Variables
    // MARK: Public
    
    var type: String
    var name: String
    var on: Bool
    var brightness: UInt8
    var hue: UInt16
    var saturation: UInt8
    var reachable: Bool
    
    enum LightKeys: String, CodingKey {
        case type
        case name
        case state
    }
    
    enum LightStateKeys: String, CodingKey {
        case on
        case brightness = "bri"
        case hue
        case saturation = "sat"
        case reachable
    }
    
    required init(from decoder: Decoder) throws {
        let lightValues = try decoder.container(keyedBy: LightKeys.self)
        type = try lightValues.decode(String.self, forKey: .type)
        name = try lightValues.decode(String.self, forKey: .name)
        
        let stateInfo = try lightValues.nestedContainer(keyedBy: LightStateKeys.self, forKey: .state)
        on = try stateInfo.decode(Bool.self, forKey: .on)
        brightness = try stateInfo.decode(UInt8.self, forKey: .brightness)
        hue = try stateInfo.decode(UInt16.self, forKey: .hue)
        saturation = try stateInfo.decode(UInt8.self, forKey: .saturation)
        reachable = try stateInfo.decode(Bool.self, forKey: .reachable)
    }
    
}
