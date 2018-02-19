//
//  Router.swift
//  HueExpression
//
//  Created by Kyle Haptonstall on 2/17/18.
//  Copyright © 2018 Kyle Haptonstall. All rights reserved.
//

import Foundation

protocol Router {
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: [String: Any]? { get }
    
    func generateURLRequest() -> URLRequest
}

extension Router {
    
    //TODO: Generate errors/throw here
    func generateURLRequest() -> URLRequest {
        let url = ServerController.apiBaseURL
        
        switch method {
        case .get, .delete:
            //URL encoded parameters
            
            guard var urlComponents = URLComponents(string: url.appendingPathComponent(path).absoluteString) else {
                fatalError()
            }
            
            if let parameters = parameters {
                urlComponents.queryItems = parameters.keys.flatMap({ URLQueryItem(name: $0, value: String(describing: parameters[$0])) })
            }
            
            guard let encodedURL = urlComponents.url else {
                fatalError()
            }
            
            var urlRequest = URLRequest(url: encodedURL)
            urlRequest.httpMethod = method.rawValue
            return urlRequest
            
        case .post, .put:
            //HTTP body encoded parametersd
            var urlRequest = URLRequest(url: url.appendingPathComponent(path))
            urlRequest.httpMethod = method.rawValue
            
            if let parameters = parameters {
                guard let jsonBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
                    fatalError()
                }
                urlRequest.httpBody = jsonBody
            }
            
            return urlRequest
        }
    }
    
}
