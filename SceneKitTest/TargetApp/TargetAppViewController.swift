//
//  TargetAppViewController.swift
//  SceneKitTest
//
//  Created by kiwan on 2020/05/12.
//  Copyright © 2020 이기완. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class TargetAppViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var lastContactNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.debugOptions = [.showWorldOrigin]
        
        // Create a new scene
        let scene = SCNScene()
        
        let box1 = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        box1.materials = [material]
        
        let box1Node = SCNNode(geometry: box1)
        let box2Node = SCNNode(geometry: box1)
        let box3Node = SCNNode(geometry: box1)
        
        box1Node.name = "Barrier1"
        box2Node.name = "Barrier2"
        box3Node.name = "Barrier3"
        
        box1Node.position = SCNVector3(0, 0, -0.4)
        box2Node.position = SCNVector3(-0.2, 0, -0.4)
        box3Node.position = SCNVector3(0.2, 0.2, -0.5)
        
        box1Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        box2Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        box3Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        
        box1Node.physicsBody?.categoryBitMask = BodyType.barrier.rawValue
        box2Node.physicsBody?.categoryBitMask = BodyType.barrier.rawValue
        box3Node.physicsBody?.categoryBitMask = BodyType.barrier.rawValue
        
        
        scene.rootNode.addChildNode(box1Node)
        scene.rootNode.addChildNode(box2Node)
        scene.rootNode.addChildNode(box3Node)
        
        sceneView.scene = scene
        
        sceneView.scene.physicsWorld.contactDelegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(shoot))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    //MARK: - Event
    @objc func shoot(recognizer: UITapGestureRecognizer) {
        guard let currentFrame = self.sceneView.session.currentFrame else {
            return
        }
                
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.3
//        print("translation = " , translation)
        
        let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.yellow
        box.materials = [material]
        
        let boxNode = SCNNode(geometry: box)
        boxNode.name = "Bullet"
        boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        boxNode.physicsBody?.isAffectedByGravity = false
        boxNode.physicsBody?.categoryBitMask = BodyType.bullet.rawValue
        boxNode.physicsBody?.contactTestBitMask = BodyType.barrier.rawValue
        
        boxNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
        let forceVector = SCNVector3(boxNode.worldFront.x * 2, boxNode.worldFront.y * 2, boxNode.worldFront.z * 2)
        boxNode.physicsBody?.applyForce(forceVector, asImpulse: true)
        
        self.sceneView.scene.rootNode.addChildNode(boxNode)
    }
    
    //MARK: - SCNPhysicsContactDelegate
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
    //MARK: - SCNPhysicsContactDelegate
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {

        let contactNode: SCNNode!
        if contact.nodeA.name == "Bullet" {
            contactNode = contact.nodeB
        }
        else {
            contactNode = contact.nodeA
        }
        
        if self.lastContactNode != nil && self.lastContactNode == contactNode {
            return
        }
        self.lastContactNode = contactNode
       
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        
        box.materials = [material]
        
        self.lastContactNode.geometry = box
    }
}
