//
//  MeasurementViewController.swift
//  SceneKitTest
//
//  Created by kiwan on 2020/05/18.
//  Copyright © 2020 이기완. All rights reserved.
//

import Foundation
import ARKit

class MeasurementViewController: UIViewController, ARSCNViewDelegate {
    
    var spheres: [SCNNode] = []
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        self.addCrossSign()
        
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
    
    private func addCrossSign() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 33))
        label.text = "+"
        label.center = self.sceneView.center
        label.textAlignment = .center
        
        sceneView.addSubview(label)
    }
    
    
    //MARK: - Event
    
    @objc private func tapped(recognizer: UITapGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = sceneView.center
        
        let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
        
        if !hitTestResults.isEmpty {
            guard let hitTestResult = hitTestResults.first  else {
                return
            }
            
            let sphere = SCNSphere(radius: 0.005)
            
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.red
            
            sphere.firstMaterial = material
            
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.position = SCNVector3(hitTestResult.worldTransform.columns.3.x, hitTestResult.worldTransform.columns.3.y, hitTestResult.worldTransform.columns.3.z)
            
            sceneView.scene.rootNode.addChildNode(sphereNode)
            
            self.spheres.append(sphereNode)
            
            if self.spheres.count == 2 {
                let firstPoint = spheres.first!
                let secondPoint = spheres.last!
                
                let point = SCNVector3Make(secondPoint.position.x - firstPoint.position.x, secondPoint.position.y - firstPoint.position.y, secondPoint.position.z - firstPoint.position.z)
                
                let distance = sqrt(point.x * point.x + point.y * point.y + point.z * point.z)
            
                let centerPoint = SCNVector3Make((secondPoint.position.x + firstPoint.position.x) / 2, (secondPoint.position.y + firstPoint.position.y) / 2, (secondPoint.position.z + firstPoint.position.z) / 2)
                
                display(distance: distance, position: centerPoint)
            }
        }
    }
    
    
    private func display(distance: Float, position: SCNVector3) {
        let text = SCNText(string: "\(distance) m", extrusionDepth: 1.0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.black
        
        text.firstMaterial = material
        
        let textNode = SCNNode(geometry: text)
        textNode.position = position
        textNode.scale = SCNVector3(0.002, 0.002, 0.002)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
}
