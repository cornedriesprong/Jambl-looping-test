//
//  DisplayLink.swift
//  Jambl_Loops_Test
//
//  Created by Corné Driesprong on 31/08/2023.
//

import UIKit

final class DisplayLink {
    
    typealias Callback = () -> Void
    
    var displayLink: CADisplayLink?
    var callback: Callback?

    func start(_ callback: @escaping Callback) {
        self.callback = callback
        
        displayLink = CADisplayLink(
            target: self,
            selector: #selector(step))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc func step(displaylink: CADisplayLink) {
        callback?()
    }
}
