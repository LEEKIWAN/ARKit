//
//  RemoteCarViewController.swift
//  SceneKitTest
//
//  Created by kiwan on 2020/05/20.
//  Copyright © 2020 이기완. All rights reserved.
//

import Foundation
import ARKit

class RemoteCarViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var carNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        
        let carScene = SCNScene(named: "car.dae")
        carNode = carScene?.rootNode.childNode(withName: "Car", recursively: true)
        
        carNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: carNode, options: nil) )
        carNode.categoryBitMask = BodyType.car.rawValue
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        
        setupControlPad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    //MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        let overlayplane = OverlayPlane(anchor: anchor as! ARPlaneAnchor)
        node.addChildNode(overlayplane)
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let plane = node.childNodes.first as? OverlayPlane else {
            return
        }
        
        plane.update(anchor: anchor as! ARPlaneAnchor)
    }
    
    private func setupControlPad() {
        let leftButton = GameButton(frame: CGRect(x: 15, y: sceneView.frame.size.height - 150, width: 50, height: 50)) {
            self.carNode.physicsBody?.applyTorque(SCNVector4(0, 1, 0, 0.1), asImpulse: false)
        }
        leftButton.setTitle("Left", for: .normal)
        
        let rightButton = GameButton(frame: CGRect(x: 75, y: sceneView.frame.size.height - 150, width: 50, height: 50)) {
            self.carNode.physicsBody?.applyTorque(SCNVector4(0, 1, 0, -0.1), asImpulse: false)
        }
        rightButton.setTitle("Right", for: .normal)
        
        let accelerateButton = GameButton(frame: CGRect(x: sceneView.frame.size.width - 110, y: sceneView.frame.size.height - 135, width: 60, height: 20)) {
            let force = simd_make_float4(0, 0, -10, 0)
            
            self.carNode.simdWorldTransform
            
            let rotatedForce = simd_mul(self.carNode.simdWorldTransform, force)
            let forceVector = SCNVector3(rotatedForce.x, rotatedForce.y, rotatedForce.z)
            
            self.carNode.physicsBody?.applyForce(forceVector, asImpulse: false)

        }
        
        accelerateButton.layer.masksToBounds = true
        accelerateButton.layer.cornerRadius = accelerateButton.frame.size.height / 2
        accelerateButton.backgroundColor = .red
        
        sceneView.addSubview(leftButton)
        sceneView.addSubview(rightButton)
        sceneView.addSubview(accelerateButton)
    }
    
    //MARK: - Event
    
    @objc func tapped(recognizer: UITapGestureRecognizer) {
        guard let sceneView = recognizer.view as? ARSCNView else {
            print("not SceneView")
            return
        }
        let touchPoint = recognizer.location(in: sceneView)
        
        let hitTestResults = sceneView.hitTest(touchPoint, types: .existingPlaneUsingExtent)
        
        if hitTestResults.count > 0 {
            let hitTestResult = hitTestResults.first!
            
            carNode.position = SCNVector3(hitTestResult.worldTransform.columns.3.x, hitTestResult.worldTransform.columns.3.y + 0.1, hitTestResult.worldTransform.columns.3.z)
            
            sceneView.scene.rootNode.addChildNode(carNode)
        }
    }
    
}
