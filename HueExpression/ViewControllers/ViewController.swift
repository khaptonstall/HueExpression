//
//  ViewController.swift
//  HueExpression
//
//  Created by Kyle Haptonstall on 1/8/18.
//  Copyright © 2018 Kyle Haptonstall. All rights reserved.
//

import ARKit
import AVFoundation
import UIKit

class ViewController: UIViewController {

    private enum Constant {
        static let instructionLabelDefault = "Smile or Frown to change light colors"
    }
    
    // MARK: - Variables
    // MARK: Private
    
    @IBOutlet private weak var instructionsLabel: UILabel!
    @IBOutlet private weak var liveCameraView: UIView!

    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var arSession = ARSession()
    private var isLoading = false
    private var lightIsOn = true
    private var lastExpressionType: ExpressionType?
    
    // MARK: Lazy
    
    lazy private var avSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        return session
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard ARFaceTrackingConfiguration.isSupported,
            let frontCamera = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.front).devices.first,
            let captureInput = try? AVCaptureDeviceInput(device: frontCamera) else {
                return
        }

        avSession.addInput(captureInput)
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: avSession)
        videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspect
        videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        liveCameraView.layer.insertSublayer(videoPreviewLayer!, at: 0)
        avSession.startRunning()

        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        arSession.delegate = self
        arSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = liveCameraView.bounds
    }
    
    // MARK: Button Actions
    
    @IBAction private func testLightButtonPressed(_ sender: Any) {
        guard !isLoading else {
            return
        }
        
        isLoading = true
        ServerController.shared.changeLightState(isOn: lightIsOn) {
            self.lightIsOn = !self.lightIsOn
            self.isLoading = false
        }
    }
    
    // MARK: Private Methods
    
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
        
        ServerController.shared.updateLightHue(withType: type) {
            self.lastExpressionType = type
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false
                , block: { (_) in
                    DispatchQueue.main.async {
                        self.instructionsLabel.text = Constant.instructionLabelDefault
                        self.isLoading = false
                    }
            })
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
            let mouthSmileRight = faceAnchor.blendShapes[.mouthSmileRight] as? Float else {
                return
        }
        
        if mouthSmileLeft > 0.5 && mouthSmileRight > 0.5 {
            updateLight(withHueType: .happy)
        } else if mouthSmileLeft < 0.2 && mouthSmileRight < 0.2 {
            updateLight(withHueType: .mad)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
