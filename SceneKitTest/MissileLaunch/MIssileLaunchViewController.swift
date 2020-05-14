//
//  ViewController.swift
//  SceneKitTest
//
//  Created by 이기완 on 2020/05/08.
//  Copyright © 2020 이기완. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class MIssileLaunchViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let missileScene = SCNScene(named: "art.scnassets/missile-1.scn")!
        
        let missile = Missile(scene: missileScene)
        missile.name = "Missile"
        missile.position = SCNVector3(0, 0, -4)
                
        let scene = SCNScene()
        scene.rootNode.addChildNode(missile)
        
        sceneView.scene = scene
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
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

    @objc func tapped(recognizer: UITapGestureRecognizer) {
        guard let missileNode = self.sceneView.scene.rootNode.childNode(withName: "Missile", recursively: true) else {
            fatalError()
        }
        
        guard let smokeNode = missileNode.childNode(withName: "smokeNode", recursively: true) else {
            fatalError()
        }
        
        smokeNode.removeAllParticleSystems()
        
        let fire = SCNParticleSystem(named: "fire.scnp", inDirectory: nil)
        smokeNode.addParticleSystem(fire!)
        
        missileNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        missileNode.physicsBody?.isAffectedByGravity = false
        missileNode.physicsBody?.damping = 0.0
        
        missileNode.physicsBody?.applyForce(SCNVector3(0, 40, 0) , asImpulse: false)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
