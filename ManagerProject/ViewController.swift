//
//  ViewController.swift
//  ManagerProject
//
//  Created by Oleh Busko on 02/08/2017.
//  Copyright © 2017 Oleh Busko. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    var isLoaded: Bool?
    var objectAdded: Bool?
    var selectedIndex: Int?
    var rotateStarted: Bool?
    var screenCenter: CGPoint?
    var selectedTextureIndex: Int?
    var selectedScaleDirection: Int?
    var startingNodeRotation: Float?
    var scale: UIPanGestureRecognizer?
    var focusColor = UIColor(rgb:0x75B7B7)
    var rotate: UIRotationGestureRecognizer?
    
    var moveZGesture: UIPanGestureRecognizer?
    var moveXYGesture: UIPanGestureRecognizer?
    var scaleGesture: UIPinchGestureRecognizer?
    var rotateGesture: UIRotationGestureRecognizer?
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var gestureView: UIView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var addObjectButton: UIButton!
    @IBOutlet weak var measurementLabel: UILabel!
    @IBOutlet weak var moveZImageView: UIImageView!
    @IBOutlet weak var scaleImageView: UIImageView!
    @IBOutlet weak var rotateImageView: UIImageView!
    @IBOutlet weak var moveXYImageView: UIImageView!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textureSelectionView: UIView!
    @IBOutlet weak var textureOneView: UIImageView!
    @IBOutlet weak var textureTwoView: UIImageView!
    @IBOutlet weak var textureThreeView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self;
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        //sceneView.autoenablesDefaultLighting = true
        //self.sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        //self.sceneView.debugOptions = ARSCNDebugOptions.showWorldOrigin
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        DispatchQueue.main.async {
            self.screenCenter = self.sceneView.bounds.mid
        }
        
        selectedIndex = 0
        selectedTextureIndex = 1
        
        let focusNode = SCNNode()
        focusNode.name = "focus"
        scene.rootNode.addChildNode(focusNode)

        self.bottomViewHeightConstraint.constant = 0
        self.view.layoutIfNeeded()
        
        self.moveZGesture = UIPanGestureRecognizer(target:self, action:#selector(self.moveZGestureResponder(_:)))
        self.moveXYGesture = UIPanGestureRecognizer(target:self, action:#selector(self.moveXYGestureResponder(_:)))
        self.scaleGesture = UIPinchGestureRecognizer(target:self, action:#selector(self.scaleGestureResponder(_:)))
        self.rotateGesture = UIRotationGestureRecognizer(target:self, action:#selector(self.rotateGestureResponder(_:)))
        
        self.moveZGesture?.cancelsTouchesInView = false
        self.scaleGesture?.cancelsTouchesInView = false
        self.moveXYGesture?.cancelsTouchesInView = false
        self.rotateGesture?.cancelsTouchesInView = false
     
        self.moveXYImageView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        
        self.textureSelectionView.alpha = 0
        selectedTextureIndex = 1
        changeBorderOfView(view: textureOneView)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func openSettings(_ sender: Any) {
        //performSegue(withIdentifier: "openSettings", sender: self)
        openSettings()
    }
    
    
    @IBAction func restartAction(_ sender: Any) {
        refresh()
    }
    
    
    @IBAction func selectTextureOne(_ sender: UITapGestureRecognizer) {
        resetAllTextureView()
        selectedTextureIndex = 1
        changeBorderOfView(view: textureOneView)
        closeSettings()
    }
    
    @IBAction func selectTextureTwo(_ sender: UITapGestureRecognizer) {
        resetAllTextureView()
        selectedTextureIndex = 2
        changeBorderOfView(view: textureTwoView)
        closeSettings()
    }
    
    @IBAction func selectTextureThree(_ sender: UITapGestureRecognizer) {
        resetAllTextureView()
        selectedTextureIndex = 3
        changeBorderOfView(view: textureThreeView)
        closeSettings()
    }
    
    func resetAllTextureView() {
        self.textureOneView.layer.borderWidth = 0
        self.textureTwoView.layer.borderWidth = 0
        self.textureThreeView.layer.borderWidth = 0
    }
    
    func changeBorderOfView(view: UIView) {
        view.layer.borderColor = UIColor.green.cgColor
        view.layer.borderWidth = 2
        view.layer.masksToBounds = true
    }
    
    func openSettings() {
        self.gestureView.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.4, animations: {
            self.textureSelectionView.alpha = 1
            self.gestureView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        })
    }
    
    func closeSettings() {
        self.gestureView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.4, animations: {
            self.textureSelectionView.alpha = 0
            self.gestureView.backgroundColor = UIColor.clear
        })
        
        if objectAdded! {
            guard let node = self.sceneView.scene.rootNode.childNode(withName: "windowsill", recursively: true) else { return }
            if selectedTextureIndex == 1 {
                node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "texture1")
            }else if selectedTextureIndex == 2{
                node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "texture2")
            }else {
                node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "texture3")
            }
        }
    }
    
    @IBAction func selectMoveXY(_ sender: UITapGestureRecognizer) {
        changeSelectionButtonColor()
        self.moveXYImageView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        
        self.sceneView.removeGestureRecognizer((self.sceneView.gestureRecognizers?.last)!)
        self.sceneView.addGestureRecognizer(moveXYGesture!)
    }
    
    @IBAction func selectMoveZ(_ sender: UITapGestureRecognizer) {
        changeSelectionButtonColor()
        self.moveZImageView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        
        self.sceneView.removeGestureRecognizer((self.sceneView.gestureRecognizers?.last)!)
        self.sceneView.addGestureRecognizer(moveZGesture!)
    }
    
    @IBAction func selectRotate(_ sender: UITapGestureRecognizer) {
        changeSelectionButtonColor()
        self.rotateImageView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        
        self.sceneView.removeGestureRecognizer((self.sceneView.gestureRecognizers?.last)!)
        self.sceneView.addGestureRecognizer(rotateGesture!)
    }
    
    @IBAction func selectScale(_ sender: UITapGestureRecognizer) {
        changeSelectionButtonColor()
        self.scaleImageView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        
        self.sceneView.removeGestureRecognizer((self.sceneView.gestureRecognizers?.last)!)
        self.sceneView.addGestureRecognizer(scaleGesture!)
    }
    
    func changeSelectionButtonColor() {
        self.scaleImageView.backgroundColor = UIColor.clear
        self.moveZImageView.backgroundColor = UIColor.clear
        self.moveXYImageView.backgroundColor = UIColor.clear
        self.rotateImageView.backgroundColor = UIColor.clear
    }
    
    @objc func rotateGestureResponder(_ sender: UIRotationGestureRecognizer) {
        guard let node = self.sceneView.scene.rootNode.childNode(withName: "windowsill", recursively: true) else { return }

        if sender.state == UIGestureRecognizerState.began {
            self.startingNodeRotation = node.rotation.w
        }
        if sender.state == UIGestureRecognizerState.changed {
            if objectAdded! {
                node.rotation = SCNVector4(0, 1, 0, self.startingNodeRotation! - Float(sender.rotation))
            }
        }
    }
    
    @objc func scaleGestureResponder(_ sender: UIPinchGestureRecognizer) {
        guard let node = self.sceneView.scene.rootNode.childNode(withName: "windowsill", recursively: true) else { return }
        let scaleFactor = sender.scale > 1 ? 1.01 : 0.99
        
        if selectedScaleDirection == 1 {
            node.scale = SCNVector3Make(node.scale.x * Float(scaleFactor), node.scale.y, node.scale.z)
        } else if selectedScaleDirection == 2{
            node.scale = SCNVector3Make(node.scale.x, node.scale.y, node.scale.z * Float(scaleFactor))
        }
        setMeasurementLabel()
    }
    
    @objc func moveZGestureResponder(_ sender: UIPanGestureRecognizer) {
        guard let node = self.sceneView.scene.rootNode.childNode(withName: "windowsill", recursively: true) else { return }
        let translation = sender.translation(in: self.sceneView)
        let cameraAngle = Int(Double(getRotation() * 180) / Double.pi)
        
        if cameraAngle > 0 && cameraAngle < 90  {
            node.position = SCNVector3Make(translation.y < 0 ? node.position.x - getPositionIncreaseOne() : node.position.x + getPositionIncreaseOne(), node.position.y, translation.y < 0 ? node.position.z - getPositionIncreaseTwo() : node.position.z + getPositionIncreaseTwo())
        } else if cameraAngle >= 90 && cameraAngle < 180 {
            node.position = SCNVector3Make(translation.y < 0 ? node.position.x - getPositionIncreaseTwo() : node.position.x + getPositionIncreaseTwo(), node.position.y, translation.y < 0 ? node.position.z + getPositionIncreaseOne() : node.position.z - getPositionIncreaseOne())
        }else if cameraAngle >= -90 && cameraAngle < 0 {
            node.position = SCNVector3Make(translation.y < 0 ? node.position.x + getPositionIncreaseOne() : node.position.x - getPositionIncreaseOne(), node.position.y, translation.y < 0 ? node.position.z - getPositionIncreaseTwo() : node.position.z + getPositionIncreaseTwo())
        } else if cameraAngle > -180 && cameraAngle < -90 {
            node.position = SCNVector3Make(translation.y < 0 ? node.position.x + getPositionIncreaseTwo() : node.position.x - getPositionIncreaseTwo(), node.position.y, translation.y < 0 ? node.position.z + getPositionIncreaseOne() : node.position.z - getPositionIncreaseOne())
        }
    }
    
    func getPositionIncreaseOne() -> Float {
        let cameraAngle = Int(Double(getRotation() * 180) / Double.pi)
        
        if cameraAngle > 0 && cameraAngle < 90 {
            return Float(0.005 * Double(cameraAngle) / 50)
        } else if cameraAngle >= 90 && cameraAngle < 180 {
            return Float(0.005 * (Double(cameraAngle) - 90) / 50)
        } else if cameraAngle >= -90 && cameraAngle < 0 {
            return Float(0.005 * Double(-cameraAngle) / 50)
        } else {
            return Float(0.005 * (Double(-cameraAngle) - 90) / 50)
        }
    }
    
    func getPositionIncreaseTwo() -> Float {
        let cameraAngle = Int(Double(getRotation() * 180) / Double.pi)
        
        if cameraAngle > 0 && cameraAngle < 90 {
            return Float(0.005 * Double(90 - cameraAngle) / 50)
        } else if cameraAngle >= 90 && cameraAngle < 180 {
            return Float(0.005 * Double(90 - (cameraAngle - 90)) / 50)
        } else if cameraAngle >= -90 && cameraAngle < 0 {
            return Float(0.005 * Double(90 - (-cameraAngle)) / 50)
        } else {
            return Float(0.005 * (Double(90 - ((-cameraAngle) - 90)) / 50))
        }
    }
    
    @objc func moveXYGestureResponder(_ sender: UIPanGestureRecognizer) {
        guard let node = self.sceneView.scene.rootNode.childNode(withName: "windowsill", recursively: true) else { return }
        let translation = sender.translation(in: self.sceneView)
        let checkValue = Int(Double(getRotation() * 180) / Double.pi)

        
        if abs(translation.x) > abs(translation.y) {
            if checkValue > 0 && checkValue < 90  {
                node.position = SCNVector3Make(translation.x > 0 ? node.position.x + getPositionIncreaseTwo() : node.position.x - getPositionIncreaseTwo(), node.position.y, translation.x > 0 ? node.position.z - getPositionIncreaseOne() : node.position.z + getPositionIncreaseOne())
            } else if checkValue >= 90 && checkValue < 180 {
                node.position = SCNVector3Make(translation.x < 0 ? node.position.x + getPositionIncreaseOne() : node.position.x - getPositionIncreaseOne(), node.position.y, translation.x < 0 ? node.position.z + getPositionIncreaseTwo() : node.position.z - getPositionIncreaseTwo())
            }else if checkValue >= -90 && checkValue < 0 {
                node.position = SCNVector3Make(translation.x < 0 ? node.position.x - getPositionIncreaseTwo() : node.position.x + getPositionIncreaseTwo(), node.position.y, translation.x < 0 ? node.position.z - getPositionIncreaseOne() : node.position.z + getPositionIncreaseOne())
            } else if checkValue > -180 && checkValue < -90 {
                node.position = SCNVector3Make(translation.x > 0 ? node.position.x - getPositionIncreaseOne() : node.position.x + getPositionIncreaseOne(), node.position.y, translation.x > 0 ? node.position.z + getPositionIncreaseTwo() : node.position.z - getPositionIncreaseTwo())
            }
        } else {
            node.position = SCNVector3Make(node.position.x, translation.y > 0 ? node.position.y - 0.005 : node.position.y + 0.005, node.position.z)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for view in gestureView.subviews {
            view.removeFromSuperview()
        }
        for touch in touches {
            let touchLocation = touch.location(in: gestureView)
            addSubviewAtCoordinates(x: touchLocation.x, y: touchLocation.y)
        }
    }
    
    func addSubviewAtCoordinates(x: CGFloat, y: CGFloat) {
        let fingerView = UIView(frame: CGRect(x: x - 25, y: y - 25, width: 50, height: 50))
        fingerView.alpha = 0.5
        fingerView.isUserInteractionEnabled = false
        fingerView.backgroundColor = UIColor.red
        fingerView.layer.cornerRadius = 25
        fingerView.layer.masksToBounds = true
        
        UIView.animate(withDuration: 2, animations: {
            fingerView.alpha = 0
        })
        
        gestureView.addSubview(fingerView)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for view in gestureView.subviews {
            view.removeFromSuperview()
        }
        for touch in touches {
            let touchLocation = touch.location(in: gestureView)
            addSubviewAtCoordinates(x: touchLocation.x, y: touchLocation.y)
        }

        selectedScaleDirection = 0
        if touches.count == 2 {
            let fingerOne = touches.first?.location(in: sceneView)
            let mySetIndex = touches.index(touches.startIndex, offsetBy: 1)
            let fingerTwo = touches[mySetIndex].location(in: sceneView)

            if abs((fingerOne?.x)! - fingerTwo.x) > abs((fingerOne?.y)! - fingerTwo.y) {
                selectedScaleDirection = 1
            }else {
                selectedScaleDirection = 2
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! SettingsViewController
        destination.selectedIndex = self.selectedIndex!
        destination.selectedTextureIndex = selectedTextureIndex
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func rotateObject(_ sender: UIRotationGestureRecognizer) {
        guard let node = self.sceneView.scene.rootNode.childNode(withName: "windowsill", recursively: true) else { return }
        if sender.state == UIGestureRecognizerState.began {
            self.startingNodeRotation = node.rotation.w
            self.rotateStarted = true
        }
        if sender.state == UIGestureRecognizerState.ended {
            self.rotateStarted = false
        }
        if sender.state == UIGestureRecognizerState.changed {
            if objectAdded! {
                node.rotation = SCNVector4(0, 1, 0, self.startingNodeRotation! - Float(sender.rotation))
            }
        }
        
    }

    func createLine(position: SCNVector3, height: Float, width: Float, length: Float, name: String) -> SCNNode{
        let plane = SCNBox(width: CGFloat(width), height: CGFloat(height), length: CGFloat(length), chamferRadius: 0.0)
        let node = SCNNode(geometry:plane)
        node.name = name
        node.position = position
        node.geometry?.firstMaterial?.diffuse.contents = focusColor
        return node
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal

        refresh()
        
        sceneView.session.run(configuration)
    }
    
    func refresh() {
        
        var isFound = false
        
        for node in self.sceneView.scene.rootNode.childNodes {
            if node.name == "focus" {
                isFound = true
            }
        }
        if !isFound {
            let focusNode = SCNNode()
            focusNode.name = "focus"
            self.sceneView.scene.rootNode.addChildNode(focusNode)
        }
        
        isLoaded = false
        objectAdded = false
        rotateStarted = false
        
        for node in self.sceneView.scene.rootNode.childNodes {
            if node.name != "focus" {
                node.removeFromParentNode()
            }else {
                for focusSide in node.childNodes {
                    focusSide.removeFromParentNode()
                }
            }
        }
        
        measurementLabel.text = ""
        addObjectButton.alpha = 1
        bottomViewHeightConstraint.constant = 0
        changeSelectionButtonColor()
        selectedTextureIndex = 1
        self.moveXYImageView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        self.sceneView.removeGestureRecognizer((self.sceneView.gestureRecognizers?.last)!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    @IBAction func addObjectToView(_ sender: Any) {
        sceneView.addGestureRecognizer(moveXYGesture!)
        self.bottomViewHeightConstraint.constant = 50
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
            self.addObjectButton.alpha = 0
        })

        if isLoaded! && !objectAdded!{
            self.objectAdded = true
            let windowsillScene = SCNScene(named: "art.scnassets/windowsill.dae")
            guard let focusNode = self.sceneView.scene.rootNode.childNode(withName: "focus", recursively: true) else { return }
            guard let windowsillNode = windowsillScene?.rootNode.childNode(withName: "windowsill", recursively: true) else { return }
            guard let lightNode = windowsillScene?.rootNode.childNode(withName: "Lamp", recursively: true) else { return }
            //8.7 0.3 2.5

            windowsillNode.scale = SCNVector3Make(0.04, 0.07, 0.04)
            windowsillNode.position = SCNVector3Make(focusNode.position.x + 0.01, focusNode.position.y, focusNode.position.z - 0.01)
            windowsillNode.rotation = focusNode.rotation
            self.sceneView.scene.rootNode.addChildNode(windowsillNode)
            self.sceneView.scene.rootNode.addChildNode(lightNode)
            
            setMeasurementLabel()

            if selectedTextureIndex == 1 {
                windowsillNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "texture1")
            }else if selectedTextureIndex == 2{
                windowsillNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "texture2")
            }else {
                windowsillNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "texture3")
            }
            
            focusNode.removeFromParentNode()
        }
    }
    
    func setMeasurementLabel() {
        guard let windowsillNode = self.sceneView.scene.rootNode.childNode(withName: "windowsill", recursively: true) else { return }
        self.measurementLabel.text = "\(Int(windowsillNode.scale.x * 8.7 * 100))cm x \(Int(windowsillNode.scale.z * 2.5 * 100))cm"
    }
    
    //MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let screenCenter = screenCenter else { return }
        guard let node = self.sceneView.scene.rootNode.childNode(withName: "focus", recursively: true) else { return }
        let (worldPos, _, _) = worldPositionFromScreenPosition(screenCenter, in: self.sceneView, objectPos: node.simdPosition)
        if worldPos != nil {
            isLoaded = true

            if node.childNodes.count == 0 {
                node.addChildNode(createLine(position: SCNVector3Make(0, 0, 0.05), height: 0.00001, width: 0.1, length: 0.001, name:"top"))
                node.addChildNode(createLine(position: SCNVector3Make(0, 0, -0.05), height: 0.00001, width: 0.1, length: 0.001, name:"bottom"))
                node.addChildNode(createLine(position: SCNVector3Make(0.05, 0, 0), height: 0.00001, width: 0.001, length: 0.1, name:"right"))
                node.addChildNode(createLine(position: SCNVector3Make(-0.05, 0, 0), height: 0.00001, width: 0.001, length: 0.1, name:"left"))
            }
            
            node.position = SCNVector3Make((worldPos?.x)!, (worldPos?.y)!, (worldPos?.z)!)
            node.rotation = SCNVector4(0, 1, 0, getRotation())
        }
    }
    
    func getRotation() -> Float {
        var angle: Float = 0
        if let camera = self.sceneView.session.currentFrame?.camera {
            let tilt = abs(camera.eulerAngles.x)
            let threshold1: Float = .pi / 2 * 0.65
            let threshold2: Float = .pi / 2 * 0.75
            let yaw = atan2f(camera.transform.columns.0.x, camera.transform.columns.1.x)
            
            switch tilt {
            case 0..<threshold1:
                angle = camera.eulerAngles.y
            case threshold1..<threshold2:
                let relativeInRange = abs((tilt - threshold1) / (threshold2 - threshold1))
                let normalizedY = normalize(camera.eulerAngles.y, forMinimalRotationTo: yaw)
                angle = normalizedY * (1 - relativeInRange) + yaw * relativeInRange
            default:
                angle = yaw
            }
        }
        return angle
    }
    
    private func normalize(_ angle: Float, forMinimalRotationTo ref: Float) -> Float {
        var normalized = angle
        while abs(normalized - ref) > .pi / 4 {
            if angle > ref {
                normalized -= .pi / 2
            } else {
                normalized += .pi / 2
            }
        }
        return normalized
    }

    func worldPositionFromScreenPosition(_ position: CGPoint,
                                         in sceneView: ARSCNView,
                                         objectPos: float3?,
                                         infinitePlane: Bool = false) -> (position: float3?, planeAnchor: ARPlaneAnchor?, hitAPlane: Bool) {
        
        let planeHitTestResults = sceneView.hitTest(position, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults.first {
            
            let planeHitTestPosition = result.worldTransform.translation
            let planeAnchor = result.anchor
            
            // Return immediately - this is the best possible outcome.
            return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
        }

        var featureHitTestPosition: float3?
        var highQualityFeatureHitTestResult = false
        
        let highQualityfeatureHitTestResults = sceneView.hitTestWithFeatures(position, coneOpeningAngleInDegrees: 18, minDistance: 0.2, maxDistance: 2.0)
        
        if !highQualityfeatureHitTestResults.isEmpty {
            let result = highQualityfeatureHitTestResults[0]
            featureHitTestPosition = result.position
            highQualityFeatureHitTestResult = true
        }
        
        if highQualityFeatureHitTestResult {
            return (featureHitTestPosition, nil, false)
        }

        let unfilteredFeatureHitTestResults = sceneView.hitTestWithFeatures(position)
        if !unfilteredFeatureHitTestResults.isEmpty {
            let result = unfilteredFeatureHitTestResults[0]
            return (result.position, nil, false)
        }
        
        return (nil, nil, false)
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        refresh()
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
