//
//  OverlayPlanesViewController.swift
//  SceneKitTest
//
//  Created by 이기완 on 2020/05/03.
//  Copyright © 2020 이기완. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

enum BodyType: Int {
    case box = 1
    case plane = 2
}

class OverlayPlanesViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var planes: [OverlayPlane] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        self.registerGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    private func registerGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        let doubleTappedGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        
        doubleTappedGestureRecognizer.numberOfTapsRequired = 2
        
        tapGestureRecognizer.require(toFail: doubleTappedGestureRecognizer)
        
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.addGestureRecognizer(doubleTappedGestureRecognizer)
    }
    
    @objc func tapped(recognizer: UITapGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        if hitTestResult.count > 0 {
            let hitTest = hitTestResult.first
            
//            self.addBox(hitTest: hitTest!)
            
            self.addTable(hitTest: hitTest!)
        }
    }
    
    @objc func doubleTapped(recognizer: UITapGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(touchLocation, options: nil)
        
        if hitTestResult.count > 0 {
            let hitTest = hitTestResult.first!
            
//            guard let box = hitTest.node.geometry as? SCNBox else {
//                return
//            }
            
            hitTest.node.physicsBody?.applyForce(SCNVector3(hitTest.worldCoordinates.x, 4.0, hitTest.worldCoordinates.z * -2.0), asImpulse: true)
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
    
    private func addTable(hitTest: ARHitTestResult) {
        let tableScene = SCNScene(named: "art.scnassets/bench.dae")
        let tableNode = tableScene?.rootNode.childNode(withName: "SketchUp", recursively: true)
        
        tableNode?.position = SCNVector3(hitTest.worldTransform.columns.3.x, hitTest.worldTransform.columns.3.y, hitTest.worldTransform.columns.3.z)
        tableNode?.scale = SCNVector3(0.02, 0.02, 0.02)
        
        self.sceneView.scene.rootNode.addChildNode(tableNode!)
        
    }
    
    //MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !(anchor is ARPlaneAnchor) {
            return
        }
        
        let plane = OverlayPlane(anchor: anchor as! ARPlaneAnchor)
        self.planes.append(plane)
        
        node.addChildNode(plane)
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let plane = node.childNodes.first as? OverlayPlane else {
            return
        }
        
        plane.update(anchor: anchor as! ARPlaneAnchor)
    }
    
}
