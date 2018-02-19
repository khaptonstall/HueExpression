//
//  ServerController.swift
//  HueExpression
//
//  Created by Kyle Haptonstall on 1/11/18.
//  Copyright © 2018 Kyle Haptonstall. All rights reserved.
//

import Foundation

class ServerController {
    
    typealias ServerDataResponse<T: Decodable> = (_ data: [String: T]?, _ error: ServerError?) -> Void
    typealias ServerErrorResponse = (_ error: ServerError?) -> Void
    
    // MARK: Constants
    
    private enum Constant {
        static let hueBridgeIP = ""
        static let hueUsername = ""
        static let lightID = "1"
    }
    
    // MARK: Public Variables
    
    static var shared = ServerController()
    
    // MARK: Private Variables
    
    static var apiBaseURL: URL {
        guard let url = URL(string: "http://\(Constant.hueBridgeIP)/api/\(Constant.hueUsername)/") else {
            fatalError("Unable to produce base API url")
        }
        return url
    }
    
    // MARK: Public Methods
    
    func getLights(completion: @escaping ServerDataResponse<Light>) {
        performMappingRequest(withRouter: LightsRouter.getLights) { (data: [String: Light]?, error) in
            completion(data, error)
        }
    }
    
    func updateLightHue(withType type: ExpressionType, completion: @escaping ServerErrorResponse) {
        let router = LightsRouter.updateLightState(id: Constant.lightID, isOn: nil, hue: type.hueValue)
        
        performRequest(withRouter: router) { (error) in
            completion(error)
        }
    }
    
    func updateLightState(isOn: Bool, completion: @escaping ServerErrorResponse) {
        let router = LightsRouter.updateLightState(id: Constant.lightID, isOn: isOn, hue: nil)
        performRequest(withRouter: router) { (error) in
            completion(error)
        }
    }
    
    // MARK: Private Methods
    
    private func performMappingRequest<T: Decodable>(withRouter router: Router, completion: @escaping ServerDataResponse<T>) {
        let task = URLSession.shared.dataTask(with: router.generateURLRequest()) { (data, _, error) in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode([String: T].self, from: data)
                    completion(decodedData, nil)
                } catch {
                    completion(nil, ServerError.jsonParsingError)
                }
            } else if let error = error {
                completion(nil, ServerError.apiError(error: error))
            } else {
                completion(nil, nil)
            }
        }
        
        task.resume()
    }
    
    private func performRequest(withRouter router: Router, completion: @escaping ServerErrorResponse) {
        let task = URLSession.shared.dataTask(with: router.generateURLRequest()) { (_, _, error) in
            if let error = error {
                completion(ServerError.apiError(error: error))
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
}

// MARK: - ServerController + ServerError

extension ServerController {

    enum ServerError: Error {
        case jsonParsingError
        case apiError(error: Error)

        var message: String {
            switch self {
            case .apiError(let error):
                return error.localizedDescription
            case .jsonParsingError:
                return "An error occurred when parsing JSON"
            }
        }
    }

}

