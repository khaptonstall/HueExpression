//
//  ViewController.swift
//  HueExpression
//
//  Created by Kyle Haptonstall on 1/8/18.
//  Copyright © 2018 Kyle Haptonstall. All rights reserved.
//

import ARKit
import UIKit

class ViewController: UIViewController {

    private enum Constant {
        static let instructionLabelDefault = "Smile or Frown to change light colors"
    }
    
    // MARK: - Variables
    // MARK: Private
    
    @IBOutlet private weak var instructionsLabel: UILabel!

    private var arSession = ARSession()
    private var isLoading = false
    private var lightIsOn = true
    private var lastExpressionType: ExpressionType?
    private var timer: Timer?

    // MARK: Lazy
    
    lazy private var avSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        return session
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard ARFaceTrackingConfiguration.isSupported else {
            return
        }

        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        arSession.delegate = self
        arSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        getLights()
    }

    // MARK: Button Actions
    
    @IBAction private func testLightButtonPressed(_ sender: Any) {
        guard !isLoading else {
            return
        }

        isLoading = true
        ServerController.shared.updateLightState(isOn: lightIsOn) { error in
            self.isLoading = false

            if let error = error {
                DispatchQueue.main.async {
                    self.displayErrorAlert(withError: error)
                }
            } else {
                self.lightIsOn = !self.lightIsOn
            }
        }
    }
    
    // MARK: Private Methods
    
    private func getLights() {
        ServerController.shared.getLights { (lights, error) in
            if let lights = lights {
                print("Got lights: \(lights)")
            } else if let error = error {
                DispatchQueue.main.async {
                    self.displayErrorAlert(withError: error)
                }
            }
        }
    }
    
    private func updateLight(withHueType type: ExpressionType) {
        guard !isLoading,
            type != lastExpressionType else {
            return
        }

        isLoading = true

        switch type {
        case .happy:
            instructionsLabel.text = "Detected a happy expression - turning green"
        case .mad:
            instructionsLabel.text = "Detected a mad expression - turning red"
        }

        ServerController.shared.updateLightHue(withType: type) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.displayErrorAlert(withError: error)
                }
            } else {
                self.lastExpressionType = type
                DispatchQueue.main.async {
                    self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false
                        , block: { _ in
                            DispatchQueue.main.async {
                                self.instructionsLabel.text = Constant.instructionLabelDefault
                                self.isLoading = false
                            }
                    })
                }
            }
        }
    }
}

// MARK: - ARSessionDelegate

extension ViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let faceAnchor = frame.anchors.first(where: { $0 is ARFaceAnchor }) as? ARFaceAnchor else {
            return
        }
        
        guard let mouthSmileLeft =  faceAnchor.blendShapes[.mouthSmileLeft] as? Float,
            let mouthSmileRight = faceAnchor.blendShapes[.mouthSmileRight] as? Float,
            let browDownLeft = faceAnchor.blendShapes[.browDownLeft] as? Float,
            let browDownRight = faceAnchor.blendShapes[.browDownRight] as? Float else {
                return
        }
        
        if (mouthSmileLeft > 0.5 && mouthSmileRight > 0.5) && (browDownLeft < 0.1 && browDownRight < 0.1) {
            updateLight(withHueType: .happy)
        } else if (mouthSmileLeft < 0.2 && mouthSmileRight < 0.2) && (browDownLeft > 0.5 && browDownRight > 0.5)  {
            updateLight(withHueType: .mad)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}

