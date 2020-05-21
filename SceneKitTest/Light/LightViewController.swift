//
//  LightViewController.swift
//  SceneKitTest
//
//  Created by kiwan on 2020/05/20.
//  Copyright © 2020 이기완. All rights reserved.
//

import Foundation
import ARKit

class LightViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
//        sceneView.autoenablesDefaultLighting = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        insertSpotLight(position: SCNVector3(0, 1, 0))
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
        overlayplane.physicsBody?.categoryBitMask = BodyType.plane.rawValue
        node.addChildNode(overlayplane)
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let plane = node.childNodes.first as? OverlayPlane else {
            return
        }
        
        plane.update(anchor: anchor as! ARPlaneAnchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let lightEstimate = sceneView.session.currentFrame?.lightEstimate else {
            return
        }
        
        let lightNode = sceneView.scene.rootNode.childNode(withName: "LightNode", recursively: true)
        lightNode?.light?.intensity = lightEstimate.ambientIntensity
        
    }
    
    //MARK: - Event
    @objc private func tapped(recognizer: UITapGestureRecognizer) {
        guard let sceneView = recognizer.view as? ARSCNView else {
            return
        }
        
        let hitTestResults = sceneView.hitTest(recognizer.location(in: sceneView), types: .existingPlaneUsingExtent)
        
        if hitTestResults.count > 0 {
            let hitTestResult = hitTestResults.first!
            self.addBox(hitTest: hitTestResult)
        }
    }
    
    private func addBox(hitTest: ARHitTestResult) {
        
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        box.materials = [material]
        
        let boxNode = SCNNode(geometry: box)
        boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        boxNode.physicsBody?.categoryBitMask = BodyType.box.rawValue

        boxNode.position = SCNVector3(hitTest.worldTransform.columns.3.x, hitTest.worldTransform.columns.3.y + Float(0.5), hitTest.worldTransform.columns.3.z)
        
        self.sceneView.scene.rootNode.addChildNode(boxNode)
    }
    
    private func insertSpotLight(position: SCNVector3) {
        let spotLight = SCNLight()
        spotLight.type = .spot
        spotLight.spotInnerAngle = 45
        spotLight.spotOuterAngle = 45
        
        let lightNode = SCNNode()
        lightNode.light = spotLight
        lightNode.position = position
        lightNode.name = "LightNode"
        
        lightNode.eulerAngles = SCNVector3(-Double.pi/2.0,0,-0.2)
        sceneView.scene.rootNode.addChildNode(lightNode)
    }
}

