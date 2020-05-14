//
//  Missile.swift
//  SceneKitTest
//
//  Created by 이기완 on 2020/05/10.
//  Copyright © 2020 이기완. All rights reserved.
//

import ARKit

class Missile: SCNNode {
    
    private var scene: SCNScene
    
    init(scene: SCNScene) {
        self.scene = scene
        super.init()
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        guard let missileNode = self.scene.rootNode.childNode(withName: "missileNode", recursively: true),
        let smokeNode = self.scene.rootNode.childNode(withName: "smokeNode", recursively: true) else {
            return
        }
        
        
        let smoke = SCNParticleSystem(named: "smoke.scnp", inDirectory: nil)
        smokeNode.addParticleSystem(smoke!)
        
        self.addChildNode(missileNode)
        self.addChildNode(smokeNode)
    }
}
