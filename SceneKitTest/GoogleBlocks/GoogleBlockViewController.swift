//
//  GoogleBlockViewController.swift
//  SceneKitTest
//
//  Created by kiwan on 2020/05/19.
//  Copyright © 2020 이기완. All rights reserved.
//

import Foundation
import ARKit

class GoogleBlockViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        let dragonScene = SCNScene(named: "Dragon.dae")
        
        let dragonNode = dragonScene?.rootNode.childNode(withName: "Dragon", recursively: true)
        
        // Create a new scene
        let scene = SCNScene()
        
        scene.rootNode.addChildNode(dragonNode!)
        
        // Set the scene to the view
        sceneView.scene = scene
        
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
}
