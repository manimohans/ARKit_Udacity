//
//  Hat.swift
//  UdacityFinals_MagicHat
//
//  Created by Mani on 6/25/18.
//  Copyright © 2018 Mani. All rights reserved.
//

import SceneKit

class Hat: SCNNode {
    
    static func loadNew() -> SCNNode {
        let url = Bundle.main.url(forResource: "art.scnassets/Hat", withExtension: ".scn")!
        let hatNodeReference = SCNReferenceNode(url: url)!
        hatNodeReference.load()
        return hatNodeReference
    }
}
