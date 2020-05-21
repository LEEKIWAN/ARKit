//
//  GameButton.swift
//  SceneKitTest
//
//  Created by kiwan on 2020/05/21.
//  Copyright © 2020 이기완. All rights reserved.
//

import Foundation
import UIKit

class GameButton: UIButton {
    
    var callback: () -> ()
    var timer: Timer!
    
    init(frame: CGRect, callback: @escaping () -> ()) {
        self.callback = callback
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [weak self] (timer: Timer) in
            guard let self = self else { return }
            self.callback()
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.timer.invalidate()
    }
}
