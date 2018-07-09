//
//  ViewController.swift
//  UdacityFinals_MagicHat
//
//  Created by Mani on 6/21/18.
//  Copyright © 2018 Mani. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

final class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var magicButton: UIButton!
    @IBOutlet weak var ballButton: UIButton!
    
    private var cameraTransform: matrix_float4x4? {
        let camera = sceneView.session.currentFrame?.camera
        return camera?.transform
    }
    
    private var trackingTimer: Timer?
    private var hatNode: SCNNode?
    private var hatFloorNode: SCNNode {
        let node = SCNNode()
        node.physicsBody = SCNPhysicsBody.dynamic()
        sceneView.scene.rootNode.addChildNode(node)
        return node
    }
    private var hatNodePlaneAnchor: ARPlaneAnchor?
    
    private var balls = [Ball]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration: ARConfiguration
        
        // Check the number of degrees of freedom available on the device
        if ARWorldTrackingConfiguration.isSupported {
            configuration = ARWorldTrackingConfiguration()
            (configuration as! ARWorldTrackingConfiguration).planeDetection = .horizontal
        } else {
            configuration = AROrientationTrackingConfiguration()
        }
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func ballButtonPressed(_ sender: UIButton) {
        let ballNode = Ball()
        ballNode.applyTransformation(camera: sceneView.session.currentFrame?.camera)
        sceneView.scene.rootNode.addChildNode(ballNode)
        ballNode.applyForce(camera: sceneView.session.currentFrame?.camera)
        balls.append(ballNode)
    }
    
    @IBAction func magicButtonPressed(_ sender: UIButton) {
        
        // Hide the balls that are inside the hat
        balls.filter { $0.inside(hat: hatNode!)}
            .forEach { $0.isHidden = !$0.isHidden }
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        // Create an SCNNode for a detect ARPlaneAnchor
        guard let planeAnchor = anchor as? ARPlaneAnchor, hatNode == nil else {
            return nil
        }
        hatNodePlaneAnchor = planeAnchor
        let position = SCNVector3Make(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
        hatNode = Hat.loadNew()
        hatNode?.position = position
        
        return hatNode
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.center == hatNodePlaneAnchor?.center || hatNodePlaneAnchor == nil else {
            return
        }
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.y))
        hatFloorNode.geometry = plane
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let lightEstimate = sceneView.session.currentFrame?.lightEstimate {
            sceneView.scene.rootNode.childNode(withName: "omni", recursively: true)?.light?.intensity = lightEstimate.ambientIntensity
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            // display error to user
            break
        case .limited:
            print("Limited tracking available")
            trackingTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { [weak self] _ in
                session.run(AROrientationTrackingConfiguration())
                self?.trackingTimer?.invalidate()
                self?.trackingTimer = nil
            })
        case .normal:
            if trackingTimer != nil {
                trackingTimer!.invalidate()
                trackingTimer = nil
            }
        }
    }
}
