//
//  ViewController.swift
//  Basketball
//
//  Created by Nikolay Naumenkov on 10/07/2019.
//  Copyright © 2019 iApps. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    private func addHoop(result: ARHitTestResult) {
        let hoop = SCNScene(named: "art.scnassets/hoop.scn")!.rootNode.clone()
        hoop.simdTransform = result.worldTransform
        hoop.eulerAngles.x -= .pi / 2
        sceneView.scene.rootNode.addChildNode(hoop)

        removeAllWalls()
    }

    private func removeAllWalls() {
        sceneView.scene.rootNode.enumerateChildNodes { node, _ in
            if node.name == "Wall" {
                node.removeFromParentNode()
            }
        }
    }

    private func createWall(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let extent = planeAnchor.extent
        let width = CGFloat(extent.x)
        let height = CGFloat(extent.z)

        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/textures/grid.jpg")

        let wall = SCNNode(geometry: plane)
        wall.eulerAngles.x = -.pi / 2
        wall.opacity = 0.125
        wall.name = "Wall"

        return wall
    }

    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)

        if let nearestResult = hitTestResult.first {
            addHoop(result: nearestResult)
        }
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }

        let wall = createWall(planeAnchor: planeAnchor)
        node.addChildNode(wall)
    }
}
