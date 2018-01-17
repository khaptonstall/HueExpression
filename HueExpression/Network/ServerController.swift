//
//  ServerController.swift
//  HueExpression
//
//  Created by Kyle Haptonstall on 1/11/18.
//  Copyright © 2018 Kyle Haptonstall. All rights reserved.
//

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
            return completion()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        let parameters: [String: Any] = ["hue": type.hueValue]
        guard let jsonBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return completion()
        }
        
        request.httpBody = jsonBody
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            completion()
        }
        
        task.resume()
    }
    
    func changeLightState(isOn: Bool, completion: @escaping (() -> Void)) {
        let urlString = apiBasePath + String(format: Constant.apiURLLightStateFormat, Constant.lightID)
        guard let url = URL(string: urlString) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        let parameters: [String: Any] = ["on": isOn]
        guard let jsonBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return completion()
        }
        
        request.httpBody = jsonBody
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            completion()
        }
        
        task.resume()
    }
    
}
