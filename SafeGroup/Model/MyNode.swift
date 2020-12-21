//
//  MyNode.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 18/12/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import Foundation
import ForceDirectedScene
import SpriteKit

class MyNode {
    var skNode: SKShapeNode
    
    init(skNode: SKShapeNode) {
        self.skNode = skNode
    }
}

extension MyNode: ForceBody {

    public var position: CGPoint {
        get {
            return self.skNode.position
        }
    }
    public var charge: CGFloat {
        get {
            if let physics = self.skNode.physicsBody {
                return physics.charge
            }
            return 0.0
        }
    }
    
    public func applyForce(force: CGVector) {
        self.skNode.physicsBody?.applyForce(force)
    }
}

class MyLink {
    var skNode: SKShapeNode?
    var sourceSKNode: SKNode?
    var destinationSKNode: SKNode?
    
    init() {
        self.sourceSKNode = nil
        self.destinationSKNode = nil
        self.skNode = nil
    }
    
    init(source: SKNode, destination: SKNode, skNode: SKShapeNode? = nil) {
        self.sourceSKNode = source
        self.destinationSKNode = destination
        self.skNode = skNode
    }
}
