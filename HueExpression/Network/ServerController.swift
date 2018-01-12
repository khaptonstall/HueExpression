//
//  ServerController.swift
//  HueExpression
//
//  Created by Kyle Haptonstall on 1/11/18.
//  Copyright © 2018 Kyle Haptonstall. All rights reserved.
//

import Alamofire

class ServerController {
    
    private enum Constant {
        static let hueBridgeIP = ""
        static let hueUsername = ""
        static let lightID = "1"
        static let apiURLLightStateFormat = "/lights/%@/state"
    }
    
    // MARK: - Variables
    // MARK: Public
    
    static var shared = ServerController()
    
    // MARK: Private
    
    private var apiBasePath: String {
        return "http://\(Constant.hueBridgeIP)/api/\(Constant.hueUsername)"
    }
    
    // MARK: Public Methods
    
    func updateLightHue(withType type: ExpressionType, completion: @escaping (() -> Void)) {
        let urlString = apiBasePath + String(format: Constant.apiURLLightStateFormat, Constant.lightID)
        guard let url = URL(string: urlString) else {
            return
        }
        
        let parameters: [String: Any] = ["hue": type.hueValue]
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { response in
            print(response.result.value)
            completion()
        }
    }
    
    func changeLightState(isOn: Bool, completion: @escaping (() -> Void)) {
        let urlString = apiBasePath + String(format: Constant.apiURLLightStateFormat, Constant.lightID)
        guard let url = URL(string: urlString) else {
            return
        }
        
        let parameters: [String: Any] = ["on": isOn]
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { response in
            print(response.result.value)
            completion()
        }
    }
    
}
