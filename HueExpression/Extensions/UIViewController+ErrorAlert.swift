//
//  UIViewController+ErrorAlert.swift
//  HueExpression
//
//  Created by Kyle Haptonstall on 2/18/18.
//  Copyright © 2018 Kyle Haptonstall. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func displayErrorAlert(withError error: ServerController.ServerError) {
        let alert = UIAlertController(title: "An Error Occurred", message: error.message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
    
}
