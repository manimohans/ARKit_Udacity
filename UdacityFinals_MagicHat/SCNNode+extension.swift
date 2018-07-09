//
//  SCNNode+extension.swift
//  UdacityFinals_MagicHat
//
//  Created by Mani on 6/25/18.
//  Copyright © 2018 Mani. All rights reserved.
//

import ARKit

extension SCNNode {
    func boundingBoxContains(point: SCNVector3, in node: SCNNode) -> Bool {
        let localPoint = self.convertPosition(point, from: node)
        return boundingBoxContains(point: localPoint)
    }
    
    func boundingBoxContains(point: SCNVector3) -> Bool {
        return BoundingBox(self.boundingBox).contains(point)
    }
}

struct BoundingBox {
    let min: SCNVector3
    let max: SCNVector3
    
    init(_ boundTuple: (min: SCNVector3, max: SCNVector3)) {
        min = boundTuple.min
        max = boundTuple.max
    }
    
    func contains(_ point: SCNVector3) -> Bool {
        let contains =
            min.x <= point.x &&
                min.y <= point.y &&
                min.z <= point.z &&
                
                max.x > point.x &&
                max.y > point.y &&
                max.z > point.z
        
        return contains
    }
}
